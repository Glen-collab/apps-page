#!/usr/bin/env bash
# Generate apps.html from apps.json + template.html, with every icon inlined.
#
# Deploy is then one scp of one self-contained file. No build step on the server,
# nothing to 404, and the page renders from a local copy or an email attachment.
#
# To move an app between sections, change ONE WORD in apps.json:
#   "status": "building"  ->  "review"  ->  "live"
# then run this. Never hand-edit apps.html; it is generated.
set -euo pipefail
cd "$(dirname "$0")"

# The Mac has python3; a Windows install has python (and the Store shim on PATH
# answers `python3` with an install prompt and exit 49). Pick a real one.
PY_BIN=""
for c in python3 python py; do
  if command -v "$c" >/dev/null 2>&1 && "$c" -c 'import sys;sys.exit(0)' >/dev/null 2>&1; then
    PY_BIN="$c"; break
  fi
done
[ -n "$PY_BIN" ] || { echo "no working python found (tried python3, python, py)" >&2; exit 1; }

"$PY_BIN" - <<'PY'
import base64, json, pathlib, re, html as H

SECTIONS = [
    ("live",     "On the App Store"),
    ("review",   "In review"),
    ("building", "Being built"),
    ("web",      "On the web"),
]
BADGE = {"live": ("live", "On the App Store"), "review": ("soon", "Submitted"),
         "building": ("soon", "Coming"), "web": ("live", None)}

apps = json.loads(pathlib.Path('apps.json').read_text(encoding='utf-8'))
known = {s for s, _ in SECTIONS}
for a in apps:
    if a["status"] not in known:
        raise SystemExit(f'{a["id"]}: unknown status {a["status"]!r} — use one of {sorted(known)}')
    if a["status"] == "web" and not a.get("url"):
        raise SystemExit(f'{a["id"]}: a web app needs a url')
    if not a.get("story"):
        raise SystemExit(f'{a["id"]}: no story — the page is the copy, an app without it renders as a bare name')
    if "?utm_source" in a.get("url", ""):
        raise SystemExit(f'{a["id"]}: url carries a utm_source tag — paste artifact, strip it')

def data_uri(name):
    p = pathlib.Path('icons')/name
    if not p.exists():
        raise SystemExit(f'missing icon: {p}')
    mime = "image/svg+xml" if p.suffix == ".svg" else "image/png"
    return f'data:{mime};base64,{base64.b64encode(p.read_bytes()).decode()}'

def inline(s):
    """Escape, then honour **bold** and *italic*.

    Glen writes the emphasis himself and it carries the voice — the lines he
    leans on are the point of each entry. Escaping happens first so the markers
    are the only markup that can reach the page from apps.json.
    """
    s = H.escape(s, quote=False)
    s = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', s)
    s = re.sub(r'(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)', r'<em>\1</em>', s)
    if '*' in s:
        raise SystemExit(f'unpaired emphasis marker: {s!r}')
    return s

def card(a):
    cls, label = BADGE[a["status"]]
    if a["status"] == "web":
        badge = (f'<span class="status {cls}"><a href="{H.escape(a["url"])}" '
                 f'style="color:inherit;text-decoration:none">{H.escape(a.get("cta","Open"))} &rarr;</a></span>')
    else:
        badge = f'<span class="status {cls}">{label}</span>'
    # A paragraph starting "> " is set apart. One line has needed it so far —
    # the verse Two or Three is named after — and a quotation read as one more
    # flat paragraph loses the reason the app exists.
    story = "\n".join(
        f'      <p class="quote">{inline(p[2:])}</p>' if p.startswith('> ')
        else f'      <p>{inline(p)}</p>'
        for p in a["story"])
    return f'''    <div class="app">
      <div class="app-head">
        <img src="{data_uri(a["icon"])}" alt="">
        <div>
          <h3>{H.escape(a["name"])}</h3>
          {badge}
        </div>
      </div>
{story}
    </div>'''

blocks = []
for status, heading in SECTIONS:
    group = [a for a in apps if a["status"] == status]
    if not group:
        continue                      # an empty section is never rendered
    blocks.append(f'  <h2>{heading}</h2>\n\n' + "\n\n".join(card(a) for a in group))

page = pathlib.Path('template.html').read_text(encoding='utf-8').replace('@@APPS@@', "\n\n".join(blocks))
fav = data_uri('twoorthree.png')
page = page.replace('<link rel="icon" href="icons/twoorthree.png">', f'<link rel="icon" href="{fav}">')

assert 'icons/' not in page, "a relative icon path survived — it would 404 once deployed"
assert 'REPLACE_' not in page, "a placeholder survived"
assert '@@' not in page, "a template placeholder survived"
pathlib.Path('apps.html').write_text(page, encoding='utf-8')

counts = {s: sum(1 for a in apps if a["status"] == s) for s, _ in SECTIONS}
print(f'apps.html {round(len(page)/1024)} KB · ' + " · ".join(f"{k} {v}" for k, v in counts.items()))
PY
