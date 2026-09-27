#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run this bootstrap script as root." >&2
  exit 1
fi

DEPLOY_USER="${POCKET_GALLERY_DEPLOY_USER:-deploy}"
BASE_DIR="${POCKET_GALLERY_BASE_DIR:-/srv/pocket-gallery}"
NODE_VERSION="${POCKET_GALLERY_NODE_VERSION:-v22.20.0}"
NODE_MIRROR="${POCKET_GALLERY_NODE_MIRROR:-https://npmmirror.com/mirrors/node}"
NPM_REGISTRY="${POCKET_GALLERY_NPM_REGISTRY:-https://registry.npmmirror.com}"
DEPLOY_SCRIPT_URL="${POCKET_GALLERY_DEPLOY_SCRIPT_URL:-https://gitee.com/eurekaffeine/pocket-gallery/raw/china-version/ops/deploy-pocket-gallery.sh}"

install_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ca-certificates curl git nginx tar xz-utils util-linux
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y ca-certificates curl git nginx tar xz util-linux findutils
  elif command -v yum >/dev/null 2>&1; then
    yum install -y ca-certificates curl git nginx tar xz util-linux findutils
  else
    echo "Unsupported package manager. Install curl, git, nginx, tar, xz, util-linux and findutils manually." >&2
    exit 1
  fi
}

install_node() {
  local current_major=0 arch node_arch archive url checksum expected actual
  if command -v node >/dev/null 2>&1; then
    current_major="$(node --version | sed -E 's/^v([0-9]+).*/\1/')"
  fi
  ((current_major >= 20)) && return 0

  arch="$(uname -m)"
  case "$arch" in
    x86_64) node_arch=x64 ;;
    aarch64|arm64) node_arch=arm64 ;;
    *) echo "Unsupported CPU architecture for Node.js: $arch" >&2; exit 1 ;;
  esac

  archive="node-$NODE_VERSION-linux-$node_arch.tar.xz"
  url="$NODE_MIRROR/$NODE_VERSION/$archive"
  checksum="$(mktemp)"
  curl -fsSL "$NODE_MIRROR/$NODE_VERSION/SHASUMS256.txt" -o "$checksum"
  expected="$(awk -v file="$archive" '$2 == file {print $1}' "$checksum")"
  [[ -n "$expected" ]] || { echo "Node.js checksum not found for $archive" >&2; exit 1; }

  curl -fsSL "$url" -o "/tmp/$archive"
  actual="$(sha256sum "/tmp/$archive" | awk '{print $1}')"
  [[ "$actual" == "$expected" ]] || { echo "Node.js checksum verification failed." >&2; exit 1; }

  rm -rf "/usr/local/lib/node-$NODE_VERSION-linux-$node_arch"
  mkdir -p /usr/local/lib
  tar -xJf "/tmp/$archive" -C /usr/local/lib
  for binary in node npm npx corepack; do
    ln -sfn "/usr/local/lib/node-$NODE_VERSION-linux-$node_arch/bin/$binary" "/usr/local/bin/$binary"
  done
}

install_packages
install_node

if ! id "$DEPLOY_USER" >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash "$DEPLOY_USER"
fi

install -d -o "$DEPLOY_USER" -g "$DEPLOY_USER" -m 0755 \
  "$BASE_DIR" "$BASE_DIR/releases" "$BASE_DIR/cache"

npm install --global yarn@1.22.22 --registry "$NPM_REGISTRY"
yarn_prefix="$(npm prefix --global)"
if [[ "$yarn_prefix/bin/yarn" != /usr/local/bin/yarn ]]; then
  ln -sfn "$yarn_prefix/bin/yarn" /usr/local/bin/yarn
  ln -sfn "$yarn_prefix/bin/yarnpkg" /usr/local/bin/yarnpkg
fi
runuser -u "$DEPLOY_USER" -- /usr/local/bin/yarn config set registry "$NPM_REGISTRY"

deploy_script_tmp="$(mktemp)"
curl -fsSL "$DEPLOY_SCRIPT_URL" -o "$deploy_script_tmp"
bash -n "$deploy_script_tmp"
install -o root -g root -m 0755 "$deploy_script_tmp" /usr/local/bin/deploy-pocket-gallery
rm -f "$deploy_script_tmp"

systemctl enable --now nginx

echo
printf 'Bootstrap complete. Versions:\n'
printf '  node: '; node --version
printf '  npm:  '; npm --version
printf '  yarn: '; yarn --version
printf '  git:  '; git --version
printf '  nginx: '; nginx -v 2>&1
printf '\nInstall the Nginx configuration and TLS certificate described in docs/deployment/CHINA.md.\n'
