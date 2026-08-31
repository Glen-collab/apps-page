#!/usr/bin/env bash
# Inline every icon into a single self-contained apps.html.
#
# Deploy is then one scp of one file — no build step on the server, nothing to
# break, and the page renders from a local copy or an email attachment too.
set -euo pipefail
cd "$(dirname "$0")"
python3 - <<'PY'
import base64, re, pathlib
html = pathlib.Path('index.html').read_text()
def inline(m):
    p = pathlib.Path('icons')/f'{m.group(1)}.png'
    return f'src="data:image/png;base64,{base64.b64encode(p.read_bytes()).decode()}"'
out = re.sub(r'src="icons/([a-z]+)\.png"', inline, html)
svg = (pathlib.Path('icons')/'tracker.svg').read_bytes()
out = out.replace('src="icons/tracker.svg"',
                  f'src="data:image/svg+xml;base64,{base64.b64encode(svg).decode()}"')
fav = base64.b64encode((pathlib.Path('icons')/'twoorthree.png').read_bytes()).decode()
out = out.replace('<link rel="icon" href="icons/twoorthree.png">',
                  f'<link rel="icon" href="data:image/png;base64,{fav}">')
assert 'icons/' not in out, "a relative icon path survived — it would 404 once deployed"
pathlib.Path('apps.html').write_text(out)
print(f"apps.html {round(len(out)/1024)} KB")
PY
