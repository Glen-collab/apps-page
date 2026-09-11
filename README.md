# apps-page

> **Picking this up? Read [HANDOFF.md](HANDOFF.md) first.** It is the living status.


The apps page for **app.bestrongagain.com/apps** — everything Glen Rogers has built,
why, and how to reach him.

Plain HTML, no framework. **`apps.json` is the data, `template.html` is the page,
`build.sh` generates `apps.html`.** Never hand-edit `apps.html` — it is generated.

## Keeping it current

All links are filled in and were verified live (HTTP 200) on 2026-08-31:
`polly-connect.com`, `app.bestrongagain.com`, and `mailto:wisco.barbell@gmail.com`.

## Statuses — confirmed 2026-09-11 against the App Store

Checked against the live listings for developer `6794905380`, not against memory:
`https://itunes.apple.com/lookup?id=6794905380&entity=software&country=us`.

| Group | Apps |
|---|---|
| **On the App Store** | The Week Ender · Cabin Notes · Footsteps of the Teacher · Strongman Contest · Season Book · Spotter · MultiBooks |
| **In review** | *(empty — the section stops rendering)* |
| **Being built** | Two or Three |

**BizLedger shipped as MultiBooks.** The store listing is the name on the page;
the repo is still `business-ledger` and the bundle is still
`com.wisconsinbarbell.businessledger`.

**These go stale, so moving one is deliberately one word.** In `apps.json`:

```
"status": "building"   ->   "review"   ->   "live"
```

**A `live` app needs a `url`** — its App Store listing. The badge is that link, so
`build.sh` refuses to ship a card that says "On the App Store" and then makes the
reader go searching.

**`"android": "soon"`** adds a second badge, *Coming soon to Android*. Cabin Notes
and Season Book carry it: both have an `android/` directory in their repo, neither
is public on Play yet (Cabin Notes is through internal testing, Season Book is not
uploaded). **Delete the key the day one ships** — nothing else expires it, and a
page that keeps promising is worse than one that never did.

Then `./build.sh`. The card moves to the right section, gets the right badge, and an
emptied section stops rendering its heading entirely. `build.sh` refuses to write a
page containing a missing icon, an unknown status, a web app with no url, or a
leftover `REPLACE_` placeholder.

## Deploying

`app.bestrongagain.com` is nginx on EC2 serving `/var/www/bestrongagain/`. Follow the
golden rule from `bsa-coach-platform/docs/DEPLOYMENT_AND_GIT_SYNC.md`: **commit and
push first, then deploy.**

```bash
./build.sh

KEY=~/Desktop/polly-connect-key.pem
HOST=ec2-user@3.19.135.182

ssh -i "$KEY" "$HOST" "sudo mkdir -p /var/www/bestrongagain/apps"
scp -i "$KEY" apps.html "$HOST:/tmp/index.html"
ssh -i "$KEY" "$HOST" "sudo mv /tmp/index.html /var/www/bestrongagain/apps/index.html"

curl -s -o /dev/null -w "%{http_code}\n" https://app.bestrongagain.com/apps/   # want 200
```

**If that curl returns the coach dashboard instead of this page**, nginx is routing
`/apps/` through the React SPA's catch-all and needs a `location /apps/` block ahead
of it. That is the one thing likely to need a second pass.

Then link to it from `bestrongagain.com`, the same way "Train with me" points at
`app.bestrongagain.com`.

## What is deliberately not here

**Crucible.** Private repo, the name is a codename that must never ship, and it
holds commercial strategy about a named prospective buyer. It does not belong on a
public page.
