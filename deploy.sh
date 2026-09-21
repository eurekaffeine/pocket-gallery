#!/usr/bin/env sh

# abort on errors
set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

# build
npm run docs:build

# navigate into the build output directory
cd docs/.vuepress/dist

touch .nojekyll

git init
git add -A
git commit -m 'deploy'

# if you are deploying to https://<USERNAME>.github.io/<REPO>
git push -f https://github.com/eurekaffeine/pocket-gallery.git HEAD:gh-pages

cd -