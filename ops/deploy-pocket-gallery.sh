#!/usr/bin/env bash
set -Eeuo pipefail
umask 022

sha="${1:-}"
[[ "$sha" =~ ^[0-9a-f]{40}$ ]] || {
  echo "Usage: deploy-pocket-gallery <40-character-commit-sha>" >&2
  exit 2
}

BASE_DIR="${POCKET_GALLERY_BASE_DIR:-/srv/pocket-gallery}"
SOURCE_DIR="$BASE_DIR/source"
RELEASES_DIR="$BASE_DIR/releases"
CACHE_DIR="$BASE_DIR/cache"
CURRENT_LINK="$BASE_DIR/current"
LOCK_FILE="$BASE_DIR/deploy.lock"
GITEE_REPOSITORY="${POCKET_GALLERY_GITEE_REPOSITORY:-https://gitee.com/eurekaffeine/pocket-gallery.git}"
DEPLOY_BRANCH="${POCKET_GALLERY_DEPLOY_BRANCH:-china-version}"
SITE_HOST="${POCKET_GALLERY_SITE_HOST:-www.pocket-gallery.cn}"
HEALTHCHECK_URL="${POCKET_GALLERY_HEALTHCHECK_URL:-http://127.0.0.1/version.json}"
YARN_REGISTRY="${POCKET_GALLERY_YARN_REGISTRY:-https://registry.npmmirror.com}"
KEEP_RELEASES="${POCKET_GALLERY_KEEP_RELEASES:-7}"
YARN_BIN="${POCKET_GALLERY_YARN_BIN:-/usr/local/bin/yarn}"
[[ "$KEEP_RELEASES" =~ ^[1-9][0-9]*$ ]] || { echo "POCKET_GALLERY_KEEP_RELEASES must be a positive integer." >&2; exit 2; }

for command in git tar curl flock; do
  command -v "$command" >/dev/null 2>&1 || {
    echo "Required server command not found: $command" >&2
    exit 1
  }
done
[[ -x "$YARN_BIN" ]] || { echo "Yarn is not executable at $YARN_BIN" >&2; exit 1; }

mkdir -p "$BASE_DIR" "$RELEASES_DIR" "$CACHE_DIR"
exec 9>"$LOCK_FILE"
flock -n 9 || {
  echo "Another Pocket Gallery deployment is already running." >&2
  exit 1
}

if [[ ! -d "$SOURCE_DIR/.git" ]]; then
  git clone --no-checkout --branch "$DEPLOY_BRANCH" \
    "$GITEE_REPOSITORY" "$SOURCE_DIR"
fi

git -C "$SOURCE_DIR" remote set-url origin "$GITEE_REPOSITORY"
git -C "$SOURCE_DIR" fetch --prune origin \
  "+refs/heads/$DEPLOY_BRANCH:refs/remotes/origin/$DEPLOY_BRANCH"

remote_sha="$(git -C "$SOURCE_DIR" rev-parse "origin/$DEPLOY_BRANCH")"
if [[ "$remote_sha" != "$sha" ]]; then
  echo "Refusing deployment: Gitee $DEPLOY_BRANCH is $remote_sha, expected $sha." >&2
  exit 1
fi

git -C "$SOURCE_DIR" cat-file -e "$sha^{commit}"

release_dir="$RELEASES_DIR/$sha"
if [[ ! -s "$release_dir/index.html" ]]; then
  build_dir="$(mktemp -d "$BASE_DIR/.build.XXXXXXXX")"
  release_tmp="$RELEASES_DIR/.$sha.tmp.$$"

  cleanup() {
    rm -rf -- "${build_dir:-}" "${release_tmp:-}"
  }
  trap cleanup EXIT

  git -C "$SOURCE_DIR" archive "$sha" | tar -x -C "$build_dir"
  cd "$build_dir"

  install_server_dependencies() {
    local attempt
    if "$YARN_BIN" install --offline --frozen-lockfile --non-interactive \
      --cache-folder "$CACHE_DIR/yarn" --registry "$YARN_REGISTRY"; then
      return 0
    fi
    for attempt in 1 2 3; do
      echo "Dependency download attempt $attempt of 3..." >&2
      if "$YARN_BIN" install --frozen-lockfile --non-interactive \
        --cache-folder "$CACHE_DIR/yarn" --registry "$YARN_REGISTRY" \
        --network-timeout 120000; then
        return 0
      fi
      sleep $((attempt * 3))
    done
    return 1
  }

  install_server_dependencies
  "$YARN_BIN" docs:build

  dist_dir="$build_dir/docs/.vuepress/dist"
  test -s "$dist_dir/index.html"

  mkdir -p "$release_tmp"
  cp -a "$dist_dir/." "$release_tmp/"
  printf '{"commit":"%s","deployedAt":"%s"}\n' \
    "$sha" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >"$release_tmp/version.json"
  mv "$release_tmp" "$release_dir"
fi

previous_target="$(readlink "$CURRENT_LINK" 2>/dev/null || true)"
next_link="$BASE_DIR/.current.$sha.$$"
ln -sfn "$release_dir" "$next_link"
mv -Tf "$next_link" "$CURRENT_LINK"

rollback() {
  if [[ -n "$previous_target" ]]; then
    rollback_link="$BASE_DIR/.rollback.$$"
    ln -sfn "$previous_target" "$rollback_link"
    mv -Tf "$rollback_link" "$CURRENT_LINK"
    echo "Rolled back to $previous_target" >&2
  else
    rm -f -- "$CURRENT_LINK"
    echo "Removed failed initial release from current." >&2
  fi
}

health_body="$(curl --fail --silent --show-error \
  --max-time 20 --header "Host: $SITE_HOST" "$HEALTHCHECK_URL")" || {
  rollback
  echo "Nginx health check failed." >&2
  exit 1
}

if [[ "$health_body" != *"\"commit\":\"$sha\""* ]]; then
  rollback
  echo "Nginx health check returned an unexpected version." >&2
  printf '%s\n' "$health_body" >&2
  exit 1
fi

mapfile -t releases < <(find "$RELEASES_DIR" -mindepth 1 -maxdepth 1 \
  -type d -name '[0-9a-f]*' -printf '%T@ %p\n' | sort -rn | cut -d' ' -f2-)
if ((${#releases[@]} > KEEP_RELEASES)); then
  for ((index = KEEP_RELEASES; index < ${#releases[@]}; index++)); do
    [[ "${releases[index]}" == "$release_dir" ]] || rm -rf -- "${releases[index]}"
  done
fi

echo "Pocket Gallery China deployed successfully: $sha"
