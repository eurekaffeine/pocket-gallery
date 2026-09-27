#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

CONFIG_FILE="${POCKET_GALLERY_DEPLOY_CONFIG:-$REPO_ROOT/.env.deploy.local}"
if [[ -f "$CONFIG_FILE" ]]; then
  # This file is local-only and must contain trusted shell assignments.
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi

BRANCH="${CHINA_BRANCH:-china-version}"
GITEE_PUSH_REMOTE="${GITEE_PUSH_REMOTE:-git@gitee.com:eurekaffeine/pocket-gallery.git}"
ALIYUN_PROFILE="${ALIYUN_PROFILE:-pocket-gallery}"
CHINA_SITE_URL="${CHINA_SITE_URL:-https://www.pocket-gallery.cn}"
SKIP_LOCAL_BUILD=false
DRY_RUN=false

usage() {
  cat <<'USAGE'
Usage: scripts/publish-china.sh [--skip-local-build] [--dry-run]

Builds china-version, pushes the same commit to GitHub and Gitee, runs the
ECS deployment through Alibaba Cloud Assistant, and verifies version.json.

Required local configuration in .env.deploy.local:
  ALIYUN_REGION=cn-shanghai
  ALIYUN_INSTANCE_ID=i-xxxxxxxxxxxxxxxxx

Optional:
  ALIYUN_PROFILE=pocket-gallery
  CHINA_SITE_URL=https://www.pocket-gallery.cn
  GITEE_PUSH_REMOTE=git@gitee.com:eurekaffeine/pocket-gallery.git
USAGE
}

while (($#)); do
  case "$1" in
    --skip-local-build) SKIP_LOCAL_BUILD=true ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Required command not found: $1" >&2
    exit 1
  }
}

for command in git yarn npm aliyun jq curl base64; do
  require_command "$command"
done

: "${ALIYUN_REGION:?Set ALIYUN_REGION in .env.deploy.local}"
: "${ALIYUN_INSTANCE_ID:?Set ALIYUN_INSTANCE_ID in .env.deploy.local}"

current_branch="$(git branch --show-current)"
if [[ "$current_branch" != "$BRANCH" ]]; then
  echo "Refusing to publish '$current_branch'. Check out '$BRANCH' first." >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "The working tree must be clean before publication." >&2
  git status --short >&2
  exit 1
fi

git fetch origin "$BRANCH"
if ! git merge-base --is-ancestor "origin/$BRANCH" HEAD; then
  echo "Local $BRANCH is behind or diverged from origin/$BRANCH." >&2
  echo "Synchronize it before publishing (normally: git pull --ff-only)." >&2
  exit 1
fi

sha="$(git rev-parse HEAD)"
[[ "$sha" =~ ^[0-9a-f]{40}$ ]] || {
  echo "Could not determine a valid commit SHA." >&2
  exit 1
}

echo "Publishing Pocket Gallery China commit $sha"

LOCAL_YARN_REGISTRY="${POCKET_GALLERY_LOCAL_YARN_REGISTRY:-$(npm config get registry)}"
LOCAL_YARN_CACHE="${POCKET_GALLERY_LOCAL_YARN_CACHE:-$REPO_ROOT/.deployment-cache/yarn}"

install_local_dependencies() {
  local attempt
  if yarn install --offline --frozen-lockfile --non-interactive \
    --registry "$LOCAL_YARN_REGISTRY" --cache-folder "$LOCAL_YARN_CACHE"; then
    return 0
  fi
  for attempt in 1 2 3; do
    echo "Dependency download attempt $attempt of 3..." >&2
    if yarn install --frozen-lockfile --non-interactive \
      --registry "$LOCAL_YARN_REGISTRY" --cache-folder "$LOCAL_YARN_CACHE" \
      --network-timeout 120000; then
      return 0
    fi
    sleep $((attempt * 3))
  done
  return 1
}

if [[ "$SKIP_LOCAL_BUILD" == false ]]; then
  install_local_dependencies
  yarn docs:build
  test -s docs/.vuepress/dist/index.html
fi

if [[ "$DRY_RUN" == true ]]; then
  echo "Dry run complete; no repositories or ECS instances were changed."
  exit 0
fi

# Never force push: a divergence must be resolved explicitly.
git push origin "HEAD:refs/heads/$BRANCH"
git push "$GITEE_PUSH_REMOTE" "HEAD:refs/heads/$BRANCH"

gitee_sha="$(git ls-remote "$GITEE_PUSH_REMOTE" "refs/heads/$BRANCH" | awk '{print $1}')"
if [[ "$gitee_sha" != "$sha" ]]; then
  echo "Gitee verification failed: expected $sha, received ${gitee_sha:-nothing}." >&2
  exit 1
fi

echo "Gitee verified at $sha"

aliyun_cli=(aliyun --profile "$ALIYUN_PROFILE")

assistant_status="$(
  "${aliyun_cli[@]}" ecs DescribeCloudAssistantStatus \
    --RegionId "$ALIYUN_REGION" \
    --InstanceId.1 "$ALIYUN_INSTANCE_ID"
)"

if ! jq -e \
  '.InstanceCloudAssistantStatusSet.InstanceCloudAssistantStatus[0].CloudAssistantStatus == "true"' \
  >/dev/null <<<"$assistant_status"; then
  echo "Cloud Assistant is not running on $ALIYUN_INSTANCE_ID." >&2
  jq . <<<"$assistant_status" >&2
  exit 1
fi

remote_command="/usr/local/bin/deploy-pocket-gallery '$sha'"
payload="$(printf '%s' "$remote_command" | base64 | tr -d '\n')"
client_token="pg-${sha:0:12}-$(date +%s)-$$"

response="$(
  "${aliyun_cli[@]}" ecs RunCommand \
    --RegionId "$ALIYUN_REGION" \
    --InstanceId.1 "$ALIYUN_INSTANCE_ID" \
    --Name "pocket-gallery-$sha" \
    --Type RunShellScript \
    --CommandContent "$payload" \
    --ContentEncoding Base64 \
    --Username deploy \
    --Timeout 1800 \
    --KeepCommand false \
    --ClientToken "$client_token"
)"

invoke_id="$(jq -er '.InvokeId' <<<"$response")"
echo "Alibaba Cloud invocation: $invoke_id"

for ((attempt = 1; attempt <= 600; attempt++)); do
  result="$(
    "${aliyun_cli[@]}" ecs DescribeInvocationResults \
      --RegionId "$ALIYUN_REGION" \
      --InvokeId "$invoke_id" \
      --InstanceId "$ALIYUN_INSTANCE_ID" \
      --ContentEncoding PlainText
  )"

  status="$(jq -r \
    '.Invocation.InvocationResults.InvocationResult[0].InvocationStatus // "Pending"' \
    <<<"$result")"

  case "$status" in
    Success)
      jq -r '.Invocation.InvocationResults.InvocationResult[0].Output // empty' <<<"$result"
      break
      ;;
    Pending|Running)
      sleep 3
      ;;
    *)
      jq -r '.Invocation.InvocationResults.InvocationResult[0] |
        "status=\(.InvocationStatus // "unknown") exit=\(.ExitCode // "unknown")\n\(.Output // "")\n\(.ErrorInfo // "")"' \
        <<<"$result" >&2
      echo "Aliyun deployment failed." >&2
      exit 1
      ;;
  esac

  if ((attempt == 600)); then
    echo "Timed out waiting for Aliyun deployment." >&2
    exit 1
  fi
done

version_json="$(curl --fail --silent --show-error \
  --retry 5 --retry-delay 2 \
  "$CHINA_SITE_URL/version.json?commit=$sha")"

jq -e --arg sha "$sha" '.commit == $sha' >/dev/null <<<"$version_json" || {
  echo "Public site did not report the deployed commit." >&2
  jq . <<<"$version_json" >&2
  exit 1
}

echo "Successfully deployed $sha to $CHINA_SITE_URL"
