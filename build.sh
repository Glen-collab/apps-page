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
python3 - <<'PY'
import base64, json, pathlib, html as H

SECTIONS = [
    ("live",     "On the App Store"),
    ("review",   "In review"),
    ("building", "Being built"),
    ("web",      "On the web"),
]
BADGE = {"live": ("live", "On the App Store"), "review": ("soon", "Submitted"),
         "building": ("soon", "Coming"), "web": ("live", None)}

apps = json.loads(pathlib.Path('apps.json').read_text())
known = {s for s, _ in SECTIONS}
for a in apps:
    if a["status"] not in known:
        raise SystemExit(f'{a["id"]}: unknown status {a["status"]!r} — use one of {sorted(known)}')
    if a["status"] == "web" and not a.get("url"):
        raise SystemExit(f'{a["id"]}: a web app needs a url')

def data_uri(name):
    p = pathlib.Path('icons')/name
    if not p.exists():
        raise SystemExit(f'missing icon: {p}')
    mime = "image/svg+xml" if p.suffix == ".svg" else "image/png"
    return f'data:{mime};base64,{base64.b64encode(p.read_bytes()).decode()}'

def card(a):
    cls, label = BADGE[a["status"]]
    if a["status"] == "web":
        badge = (f'<span class="status {cls}"><a href="{H.escape(a["url"])}" '
                 f'style="color:inherit;text-decoration:none">{H.escape(a.get("cta","Open"))} &rarr;</a></span>')
    else:
        badge = f'<span class="status {cls}">{label}</span>'
    return f'''    <div class="app">
      <img src="{data_uri(a["icon"])}" alt="">
      <div>
        <h3>{H.escape(a["name"])}</h3>
        <p>{H.escape(a["blurb"])}</p>
        {badge}
      </div>
    </div>'''

blocks = []
for status, heading in SECTIONS:
    group = [a for a in apps if a["status"] == status]
    if not group:
        continue                      # an empty section is never rendered
    blocks.append(f'  <h2>{heading}</h2>\n  <div class="apps">\n\n'
                  + "\n\n".join(card(a) for a in group) + "\n\n  </div>")

page = pathlib.Path('template.html').read_text().replace('@@APPS@@', "\n\n".join(blocks))
fav = data_uri('twoorthree.png')
page = page.replace('<link rel="icon" href="icons/twoorthree.png">', f'<link rel="icon" href="{fav}">')

assert 'icons/' not in page, "a relative icon path survived — it would 404 once deployed"
assert 'REPLACE_' not in page, "a placeholder survived"
pathlib.Path('apps.html').write_text(page)

counts = {s: sum(1 for a in apps if a["status"] == s) for s, _ in SECTIONS}
print(f'apps.html {round(len(page)/1024)} KB · ' + " · ".join(f"{k} {v}" for k, v in counts.items()))
PY
