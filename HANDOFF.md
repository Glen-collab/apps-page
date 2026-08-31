# apps-page — HANDOFF

> **LIVING STATUS: read this first.** Updated at the end of every working session,
> before stopping. If this file is stale, nothing else in the repo can be trusted.

*Written 2026-08-31 when this repo was created. Updated 2026-08-31 (later the same
day) after Glen rewrote every blurb in his own voice.*

---

## Where this stands

**Live.** <https://app.bestrongagain.com/apps/>, linked from bestrongagain.com
since 2026-08-31.

| Piece | State | Verified? |
|---|---|---|
| `apps.json` — the data | Complete | **Yes** — 10 apps, statuses confirmed by Glen 2026-08-31 |
| `template.html` — the page shell | Complete | **Yes** |
| `build.sh` — generator | Complete | **Yes** — status flip tested both directions; empty section drops its heading |
| `apps.html` — the deployable file | Generated, 978 KB | **Yes** — rendered and read in a browser; no stray emphasis markers, no placeholders |
| Icons | Complete | **Yes** — 9 PNGs + 1 SVG, all inlined |
| **Deployed to app.bestrongagain.com/apps** | **DONE** 2026-08-31, redeployed with the new copy | **Yes** — 200, 1,001,287 b, md5 `e115248b…` matches the committed file byte for byte |
| Link from bestrongagain.com | **DONE** 2026-08-31 | Yes — Glen linked it from the WordPress menu |

## Pick up here

**Nothing outstanding.** The page is live at <https://app.bestrongagain.com/apps/>
and linked from bestrongagain.com.

To change what it says, edit `apps.json`, run `./build.sh`, and redeploy — moving
an app between sections is one word. The deploy is one scp of one self-contained
file; see the commands below.

### The copy is the page

Each app in `apps.json` carries **`story`**, an array of paragraphs in Glen's
voice — why the app exists, not what it does. `**bold**` and `*italic*` work
inside a paragraph and nothing else does: `build.sh` escapes the string first,
so those two markers are the only markup `apps.json` can put on the page. An
unpaired marker fails the build rather than shipping a literal asterisk.

`blurb` is still there and still true — the one-line version, kept for anywhere
that needs a summary. It is **not** rendered on the page any more.

**Season Book's entry is Glen's second pass** — the one about Grandma and Grandpa
not being able to make the meet. He sent it separately from the batch and asked
for that version specifically. Do not replace it with a shorter one.

A note for whoever links it next time: bestrongagain.com is WordPress behind
Cloudflare. Adding a *page* there and pasting the URL into it produces an empty
page with the right name in the nav — the fix is a **Custom Link** menu item
pointing at the URL, not a page.

### Deployed — and the catch-all did not eat it

The worry in the note below was right to have and did not materialise. The vhost
ends with `try_files $uri $uri/ /index.html`, and a real directory satisfies
`$uri/` before the SPA fallback is reached, so no nginx change was needed.

Verified after deploying:

| | |
|---|---|
| `/apps/` | 200, 913,670 b, `<title>Apps — Glen Rogers, Be Strong Again</title>` |
| `/apps` | 301 → `https://app.bestrongagain.com/apps/` — correct scheme, no downgrade to http |
| `/` and `/checkin` | still the React app, untouched |

### One real bug found on the way: the build is not reproducible

Regenerating `apps.html` on Windows produced a **different file** from the one
the Mac committed — and not just line endings. Git was checking `tracker.svg`
out with CRLF, and `build.sh` base64-encodes the icon bytes straight into the
page, so the CRLFs ended up *inside* the data URI.

Renders identically, but it means the same commit built on two machines gives
two different pages, and a generated file that differs by platform is one nobody
can diff against what is deployed.

Fixed with a `.gitattributes` marking `*.svg -text`, `*.png binary` and
`apps.html -text`. **The deployed file is the Mac-built one** — extracted with
`git show HEAD:apps.html` rather than taken from the Windows working tree, and
md5-checked against the server after upload.

It could not be done from the Mac that built it: `~/Desktop/polly-connect-key.pem`
is referenced by `bsa-coach-platform/docs/DEPLOYMENT_AND_GIT_SYNC.md` but **is not
on that machine** — a search of the whole home directory found no `.pem` anywhere.
Glen has to run this from wherever the key actually lives.

```bash
cd apps-page && ./build.sh

KEY=~/Desktop/polly-connect-key.pem       # wherever it really is
HOST=ec2-user@3.19.135.182

ssh -i "$KEY" "$HOST" "sudo mkdir -p /var/www/bestrongagain/apps"
scp -i "$KEY" apps.html "$HOST:/tmp/index.html"
ssh -i "$KEY" "$HOST" "sudo mv /tmp/index.html /var/www/bestrongagain/apps/index.html"

curl -s -o /dev/null -w "%{http_code}\n" https://app.bestrongagain.com/apps/   # want 200
```

**The one thing likely to need a second pass:** `app.bestrongagain.com` serves a
React SPA from `/var/www/bestrongagain/`, which almost certainly has an nginx
`try_files … /index.html` catch-all. A real `/apps/` directory usually wins, but if
that curl returns the **BSA Coach dashboard** instead of the apps page, nginx needs a
`location /apps/` block placed ahead of the catch-all. Report what the curl actually
returned and it can be written from that.

Then add the link on `bestrongagain.com`, the same way *Train with me* points at
`app.bestrongagain.com`.

## Decisions made, and why

**2026-08-31 — The page is generated from `apps.json`, not hand-written.** Statuses
are the part of a portfolio that rots: apps get approved and the page quietly starts
lying. Moving one is now `"status": "building" → "review" → "live"` and a rebuild,
rather than moving an HTML block and remembering to swap the badge class. Verified
in both directions; an emptied section drops its heading rather than leaving a bare
title over nothing.

**2026-08-31 — One self-contained file, icons inlined as data URIs.** Deploy is a
single `scp` with nothing on the server to build and no asset paths to 404. It also
means the page renders from a local copy or an email attachment. Costs 892 KB, which
for a portfolio page is fine.

**2026-08-31 — `build.sh` refuses to write a broken page.** It hard-fails on a
missing icon, an unknown status, a web app with no url, or a surviving `REPLACE_`
placeholder — the four failure modes that would otherwise only surface once live.
Three more were added with the long-form copy: an app with no `story`, an
unpaired `*`, and **a url carrying `?utm_source`**. That last one is not
hypothetical — both web links arrived with a `chatgpt.com` tag attached, because
the copy was pasted out of a chat. Shipping it would have tagged Glen's own
visitors, on his own site, as arriving from somewhere they didn't.

**2026-08-31 — One app is one block, not a card with the icon beside the text.**
The stories run several paragraphs. Floating a 66px icon next to them leaves a
tall ragged column beside a small square, and the old `.95rem` `--quiet` styling
read as fine print. Icon, name and badge now sit on a header row with the story
full width underneath in body text. It is his writing; it gets to look like
writing.

**2026-08-31 — `build.sh` looks for a Python rather than assuming `python3`.**
On Windows `python3` is the Microsoft Store shim: it prints an install advert and
exits 49. The deploy key lives on the Windows machine, so the build could not run
where the deploy has to run from. It now tries `python3`, `python`, `py` and uses
the first that actually executes.

**2026-08-31 — The offer section has a filter on it, deliberately.** *"I take on a
few of these a year. I would rather finish three things properly than start ten."*
An open-ended public promise of free development would bury someone who already has
a gym, a family and 37 repos. **Do not quietly remove that line.**

**2026-08-31 — Crucible is not on this page and must not be added.** Private repo,
the name is a codename that must never ship, and it holds commercial strategy about a
named prospective buyer.

## Known traps

- **Never hand-edit `apps.html`.** It is generated. Edit `apps.json` or
  `template.html` and rebuild.
- **The page copy is Glen's, in Glen's voice.** The lede, *Why I build them*,
  *One last thing* and every `story` are his words. Fix a typo; do not smooth the
  rhythm, merge his one-line paragraphs, or make it sound like marketing. The
  short paragraphs are how he talks.
- **The statuses lie by default.** They were correct on 2026-08-31. Every approval
  makes this page wrong until someone changes one word.
- **`bsa-coach-platform` is the repo that drifts.** Its own deploy doc says live code
  often sits uncommitted there. This repo is separate on purpose — nothing here
  touches it, and no portfolio page was committed onto its `checkin-system` branch.

## Moving to another machine

This repo is **fully portable**. `build.sh` needs only `bash` and `python3` — no
Xcode, no `sips`, no Swift. It runs on Windows under WSL or Git Bash. Clone it and
work.

**What does not travel:** `Glen-collab/gathering` (the *Two or Three* iOS app) is
Swift, SwiftUI and Xcode. **It cannot be built or tested on Windows at all.** Its
own `HANDOFF.md` is current and describes where it stands; leave it for a Mac.

**Orientation for a fresh session:** read `~/hive/data/portrait.json` first — it is a
portrait of Glen derived from all 37 of his repos, with the ten rules he builds by
and what to do about each. `~/.claude/CLAUDE.md` points every session at it
automatically on the Mac; on a new machine, read it deliberately.

## Open questions for Glen

1. ~~Where is `polly-connect-key.pem`?~~ **Answered.** On the Windows machine, at
   `Desktop/polly-connect-key.pem`. Deploys run from there, or the key gets
   copied to the Mac.
2. ~~What did the verify curl return?~~ **Answered.** 200 and the apps page. The
   SPA catch-all did not swallow it and nginx needed no `location` block.
3. **Should this page eventually list the web-only work** beyond Polly and the
   Workout Tracker — the leaderboard, the family calendar, the Pi kiosks? They are
   real and they are not on it.
