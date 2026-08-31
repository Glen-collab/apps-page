# apps-page

The apps page for **app.bestrongagain.com/apps** — everything Glen Rogers has built,
why, and how to reach him.

Plain HTML, no framework, no build tooling. Edit `index.html`, run `./build.sh`,
deploy one file.

## Before it goes live

Three placeholders must be replaced. **Search for `REPLACE_` and none should remain.**

| Placeholder | What goes there |
|---|---|
| `REPLACE_WITH_EMAIL` | The address for "Tell me what you need" |
| `REPLACE_WITH_POLLY_URL` | Polly's live PWA address |
| `REPLACE_WITH_TRACKER_URL` | The Workout Tracker's live address |

**Also confirm the App Store statuses.** They are a best guess: The Week Ender,
Cabin Notes and Footsteps are shown as live; Strongman Contest and Season Book as
submitted; Two or Three, Spotter and BizLedger as coming. Wrong status on a public
page is the kind of small thing people notice.

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
