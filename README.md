# apps-page

The apps page for **app.bestrongagain.com/apps** — everything Glen Rogers has built,
why, and how to reach him.

Plain HTML, no framework, no build tooling. Edit `index.html`, run `./build.sh`,
deploy one file.

## Keeping it current

All links are filled in and were verified live (HTTP 200) on 2026-08-31:
`polly-connect.com`, `app.bestrongagain.com`, and `mailto:wisco.barbell@gmail.com`.

## Statuses — confirmed 2026-08-31

| Group | Apps |
|---|---|
| **On the App Store** | The Week Ender · Cabin Notes · Footsteps of the Teacher |
| **In review** | Strongman Contest · Season Book |
| **Being built** | Two or Three · Spotter · BizLedger |

**These go stale.** When Strongman Contest or Season Book is approved, move its
`<div class="app">` block up into the *On the App Store* section and change the
badge from `status soon` to `status live`. Same when anything ships from *Being
built*. Wrong status on a public page is the kind of small thing people notice.

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
