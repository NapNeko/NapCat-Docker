#!/bin/bash

[ "$ARCH_NC" = "linux/amd64" ] && ARCH_DOWN="x64" || [ "$ARCH_NC" = "linux/arm64" ] && ARCH_DOWN="arm64"
token="$1"
artifact_name="NapCat.linux.$ARCH_DOWN"
# 设置输出目录
output_dir="."

# 下载release
curl -s -X GET -H "Authorization: token $token" -L "https://github.com/NapNeko/NapCatQQ/releases/download/v1.0.2/$artifact_name.zip" -o "$output_dir/NapCat.linux.zip"
ls
echo "编译产物已保存到$output_dir/NapCat.linux.zip"
