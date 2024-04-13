#!/bin/bash

# 设置仓库信息
repository="NapNeko/NapCat.Build"
run_id="8662095740"
arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/x64/)
artifact_name="NapCat.linux.{$arch}"
token="$1"

# 设置输出目录
output_dir="."

# 获取artifact ID
artifact_id=$(curl -s -X GET -H "Authorization: token $token" "https://api.github.com/repos/$repository/actions/runs/$run_id/artifacts" | jq -r ".artifacts[] | select(.name == \"$artifact_name\") | .id")

# 下载artifact
curl -s -X GET -H "Authorization: token $token" -L "https://api.github.com/repos/$repository/actions/artifacts/$artifact_id/zip" -o "$output_dir/NapCat.linux.zip"

echo "编译产物已保存到$output_dir/NapCat.linux.zip"
