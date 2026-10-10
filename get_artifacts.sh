#!/bin/bash
set -euo pipefail

token="$1"
version="$2"

archive=$(mktemp ./NapCat.Shell.zip.XXXXXX)
trap 'rm -f -- "$archive"' EXIT
curl -fLsS --connect-timeout 20 --max-time 1800 \
    --proto '=http,https' --proto-redir '=http,https' \
    -H "Authorization: Bearer $token" \
    "https://github.com/NapNeko/NapCatQQ/releases/download/$version/NapCat.Shell.zip" \
    -o "$archive"
unzip -tq "$archive"
mv -- "$archive" NapCat.Shell.zip
echo "已下载 NapCat $version"
