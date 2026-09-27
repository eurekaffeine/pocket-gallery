# Pocket Gallery China deployment

The China site is published with one command:

```bash
yarn deploy:china
```

The command builds the `china-version` branch, pushes the exact commit to
GitHub and Gitee, asks Alibaba Cloud ECS Cloud Assistant to deploy it, waits for
the remote result, and verifies the public `version.json`.

## Architecture

```text
local Mac -> GitHub china-version
          -> Gitee china-version
          -> Alibaba Cloud RunCommand
             -> ECS pulls exact SHA from Gitee
             -> VitePress build
             -> /srv/pocket-gallery/releases/<SHA>
             -> atomic /srv/pocket-gallery/current symlink
             -> Nginx
```

The ECS instance never contacts GitHub. The Gitee repository is public, so the
server does not need a Gitee password or private key. The Yarn lockfile omits
registry-specific download URLs, allowing the Mac to use its configured npm
registry while ECS uses the mainland `npmmirror.com` registry.

## Information and credentials to collect

Collect these values from Alibaba Cloud before setup:

1. **ECS region ID**, for example `cn-shanghai`.
2. **ECS instance ID**, beginning with `i-`.
3. **Alibaba Cloud account UID**, used in the RAM policy resource ARN.
4. A dedicated **RAM user's AccessKey ID and AccessKey Secret** with only the
   policy in `ops/ram-policy.example.json`. The secret is shown only once.
5. If TLS is not already configured, download the certificate for
   `pocket-gallery.cn` in **Nginx format** from Alibaba Cloud Certificate
   Management Service. It must contain:
   - the certificate/full-chain PEM file;
   - the matching private-key file.

Do not commit an AccessKey Secret, TLS private key, password, or `.env.deploy.local`.
No GitHub credential is needed on ECS. No Gitee read key is needed on ECS while
the repository remains public.

The local machine still needs permission to push to both GitHub and Gitee. The
existing Git SSH keys can be used; no new key is required if both pushes already
work.

## 1. Prepare the RAM identity

Create a RAM user with **Programmatic Access only**. Copy
`ops/ram-policy.example.json`, replace:

- `ALIYUN_REGION`;
- `ACCOUNT_UID`;
- `ALIYUN_INSTANCE_ID`.

Create a custom RAM policy from the resulting JSON and attach it to the RAM
user. The policy permits commands only on the selected ECS instance and only as
the Linux user `deploy`. Read-only command-result APIs use `Resource: "*"`
because those APIs do not support narrowing to one invocation resource.

Configure the already-installed Alibaba Cloud CLI on the Mac:

```bash
aliyun configure --mode AK --profile pocket-gallery
```

Enter the dedicated RAM AccessKey ID, AccessKey Secret, and the ECS region.
Credentials are stored in the local Alibaba CLI profile, not in this repository.

## 2. Copy local configuration

```bash
cp .env.deploy.example .env.deploy.local
```

Fill in:

```bash
ALIYUN_PROFILE=pocket-gallery
ALIYUN_REGION=cn-shanghai
ALIYUN_INSTANCE_ID=i-xxxxxxxxxxxxxxxxx
```

The file is ignored by Git.

## 3. Put deployment scripts on Gitee

The bootstrap downloads the server script from the `china-version` branch, so
these files must first be merged and pushed to both hosts:

```bash
git push origin china-version
git push git@gitee.com:eurekaffeine/pocket-gallery.git china-version
```

This is the only manual two-remote push needed.

## 4. Bootstrap ECS once

Open **ECS Console -> Cloud Assistant -> Create/Run Command**, choose the
instance, select `RunShellScript`, and run as `root`:

```bash
curl -fsSL \
  https://gitee.com/eurekaffeine/pocket-gallery/raw/china-version/ops/bootstrap-ecs.sh \
  -o /tmp/bootstrap-pocket-gallery.sh

sed -n '1,260p' /tmp/bootstrap-pocket-gallery.sh
bash /tmp/bootstrap-pocket-gallery.sh
```

Reviewing the downloaded file before executing it avoids blindly piping a
network response into a root shell.

The bootstrap supports Debian/Ubuntu, Alibaba Cloud Linux, and common
RHEL/CentOS-family images. It installs Git, curl, Nginx, `flock`, Node.js 22,
Yarn 1, creates the `deploy` user, and installs
`/usr/local/bin/deploy-pocket-gallery`.

After bootstrap, verify Cloud Assistant can execute as `deploy`:

```bash
id
node --version
yarn --version
test -x /usr/local/bin/deploy-pocket-gallery
```

The final command must complete without output.

## 5. Configure Nginx and TLS

If the server already has a working HTTPS Nginx configuration, preserve its TLS
settings and change its document root to:

```nginx
root /srv/pocket-gallery/current;
```

Also expose `/version.json` with `Cache-Control: no-store` so deployment can be
verified.

For a new configuration, copy `ops/nginx-pocket-gallery.conf.example` to the
server as `/etc/nginx/conf.d/pocket-gallery.conf`. Store the Nginx certificate
files as:

```text
/etc/nginx/ssl/pocket-gallery.cn.pem
/etc/nginx/ssl/pocket-gallery.cn.key
```

Protect and test them:

```bash
sudo chown root:root /etc/nginx/ssl/pocket-gallery.cn.*
sudo chmod 600 /etc/nginx/ssl/pocket-gallery.cn.key
sudo chmod 644 /etc/nginx/ssl/pocket-gallery.cn.pem
sudo nginx -t
sudo systemctl reload nginx
```

If an Alibaba CDN sits in front of ECS, disable caching for `/version.json`.

## 6. Verify local prerequisites

```bash
aliyun version
jq --version
yarn --version

aliyun --profile pocket-gallery ecs DescribeCloudAssistantStatus \
  --RegionId "$ALIYUN_REGION" \
  --InstanceId.1 "$ALIYUN_INSTANCE_ID"
```

`CloudAssistantStatus` must be the string `true`.

Validate the repository and build without publishing:

```bash
yarn deploy:china --dry-run
```

## 7. Publish

From a clean, up-to-date `china-version` branch:

```bash
git pull --ff-only
yarn deploy:china
```

The script never force-pushes. It stops if the branch is stale, the build fails,
Gitee does not contain the exact commit, Cloud Assistant fails, or the public
site reports a different commit.

## Rollback

Every deployment is stored under `/srv/pocket-gallery/releases/<SHA>`. To roll
back, run this on ECS as `deploy`, replacing `<SHA>` with a retained release:

```bash
ln -sfn /srv/pocket-gallery/releases/<SHA> /srv/pocket-gallery/.rollback
mv -Tf /srv/pocket-gallery/.rollback /srv/pocket-gallery/current
```

The deployment script retains seven releases by default.

## Relevant official documentation

- [Create and run Cloud Assistant commands](https://www.alibabacloud.com/help/en/ecs/user-guide/use-the-immediate-execution-feature)
- [Run an existing Cloud Assistant command](https://www.alibabacloud.com/help/en/ecs/user-guide/run-a-command)
- [Restrict Cloud Assistant to regular users](https://www.alibabacloud.com/help/en/ecs/user-guide/run-cloud-assistant-commands-as-a-regular-user)
- [Configure Alibaba Cloud CLI credentials](https://www.alibabacloud.com/help/en/cli/configure-credentials/)
