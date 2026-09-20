#!/bin/sh
set -eu

locales="en zh-hans zh-hant ja-jp ko de fr es it"

swift scripts/compose-device-heroes.swift

for locale in $locales; do
  cwebp -quiet -q 92 -m 6 -alpha_q 100 \
    "docs/.vuepress/public/device-captures/$locale/pixel-10-pro-xl.png" \
    -o "docs/.vuepress/public/device-captures/$locale/pixel-10-pro-xl.webp"

  ffmpeg -hide_banner -loglevel error \
    -f lavfi -i "color=c=black@0.0:s=2400x1600,format=rgba" \
    -i "docs/.vuepress/public/device-captures/$locale/ipad-pro-13-m5-landscape.webp" \
    -i "docs/.vuepress/public/device-captures/$locale/pixel-10-pro-xl.webp" \
    -i "docs/.vuepress/public/device-captures/$locale/iphone-18-pro.webp" \
    -filter_complex "[1:v]scale=1800:1380:flags=lanczos[ipad];[2:v]scale=-1:1275:flags=lanczos[pixel];[3:v]scale=-1:1215:flags=lanczos[iphone];[0:v][ipad]overlay=135:180:format=auto[c1];[c1][pixel]overlay=185:285:format=auto[c2];[c2][iphone]overlay=1700:345:format=auto[out]" \
    -map "[out]" -frames:v 1 -y "/tmp/pocket-gallery-$locale-devices.png"

  cwebp -quiet -q 90 -m 6 -alpha_q 100 \
    "/tmp/pocket-gallery-$locale-devices.png" \
    -o "docs/.vuepress/public/heroes/$locale/devices.webp"
done

rm docs/.vuepress/public/device-captures/*/pixel-10-pro-xl.png
rm /tmp/pocket-gallery-*-devices.png
