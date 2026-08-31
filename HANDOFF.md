# apps-page — HANDOFF

> **LIVING STATUS: read this first.** Updated at the end of every working session,
> before stopping. If this file is stale, nothing else in the repo can be trusted.

*Written 2026-08-31, at the end of the session that created this repo. Picking up on
a different machine — see § Moving to another machine.*

---

## Where this stands

**Built, committed, pushed, and NOT yet deployed.** The page is finished and correct.
Nobody can see it yet.

| Piece | State | Verified? |
|---|---|---|
| `apps.json` — the data | Complete | **Yes** — 10 apps, statuses confirmed by Glen 2026-08-31 |
| `template.html` — the page shell | Complete | **Yes** |
| `build.sh` — generator | Complete | **Yes** — status flip tested both directions; empty section drops its heading |
| `apps.html` — the deployable file | Generated, 892 KB | **Yes** — all links verified HTTP 200, no placeholders remain |
| Icons | Complete | **Yes** — 9 PNGs + 1 SVG, all inlined |
| **Deployed to app.bestrongagain.com/apps** | **NOT DONE** | — |
| Link from bestrongagain.com | Not done | — |

## Pick up here

**Deploy it.** That is the only thing standing between this and being live.

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

1. **Where is `polly-connect-key.pem`?** Not on the Mac. Deployment is blocked
   without it.
2. **After deploying, what did the verify curl return** — 200 and the apps page, or
   the coach dashboard? That decides whether nginx needs a `location` block.
3. **Should this page eventually list the web-only work** beyond Polly and the
   Workout Tracker — the leaderboard, the family calendar, the Pi kiosks? They are
   real and they are not on it.
