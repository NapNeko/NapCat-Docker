#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT
mkdir -p "$work_dir/package/config" "$work_dir/napcat/config"

make_archive() {
    (cd "$work_dir/package" && "${PYTHON:-python3}" -m zipfile -c "$work_dir/NapCat.Shell.zip" napcat.mjs helper.js config)
}

install_files() {
    (cd "$work_dir" && sed -n '/^# 安装 napcat$/,/^# 配置 WebUI Token$/p' "$repo_dir/entrypoint.sh" | sed '$d' | bash)
}

assert_content() {
    if [ "$(< "$work_dir/$1")" != "$2" ]; then
        printf 'Unexpected content in %s\n' "$1" >&2
        exit 1
    fi
}

printf 'v1' > "$work_dir/package/napcat.mjs"
printf 'v1 helper' > "$work_dir/package/helper.js"
printf 'default' > "$work_dir/package/config/napcat.json"
make_archive
install_files
assert_content napcat/napcat.mjs 'v1'
assert_content napcat/config/napcat.json 'default'

printf 'custom' > "$work_dir/napcat/config/napcat.json"
printf 'webui token' > "$work_dir/napcat/config/webui.json"
rm "$work_dir/napcat/napcat.mjs"
printf 'v2' > "$work_dir/package/napcat.mjs"
printf 'v2 helper' > "$work_dir/package/helper.js"
make_archive
install_files
assert_content napcat/napcat.mjs 'v2'
assert_content napcat/helper.js 'v2 helper'
assert_content napcat/config/napcat.json 'custom'
assert_content napcat/config/webui.json 'webui token'

echo 'NapCat config survives container recreation'
