# apps-page

> **Picking this up? Read [HANDOFF.md](HANDOFF.md) first.** It is the living status.


The apps page for **app.bestrongagain.com/apps** — everything Glen Rogers has built,
why, and how to reach him.

Plain HTML, no framework. **`apps.json` is the data, `template.html` is the page,
`build.sh` generates `apps.html`.** Never hand-edit `apps.html` — it is generated.

## Keeping it current

All links are filled in and were verified live (HTTP 200) on 2026-08-31:
`polly-connect.com`, `app.bestrongagain.com`, and `mailto:wisco.barbell@gmail.com`.

## Statuses — confirmed 2026-08-31

| Group | Apps |
|---|---|
| **On the App Store** | The Week Ender · Cabin Notes · Footsteps of the Teacher |
| **In review** | Strongman Contest · Season Book |
| **Being built** | Two or Three · Spotter · BizLedger |

**These go stale, so moving one is deliberately one word.** In `apps.json`:

```
"status": "building"   ->   "review"   ->   "live"
```

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
