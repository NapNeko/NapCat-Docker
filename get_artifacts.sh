#!/bin/bash

ARCH_DOWN=$(echo $ARCH_NC | sed 's/linux\/amd64/x64/' | sed 's/linux\/arm64/arm64/')
token="$1"
artifact_name="NapCat.linux.$ARCH_DOWN"
# 设置输出目录
output_dir="."
echo "当前架构$ARCH_DOWN"
# 下载release
curl -s -X GET -H "Authorization: token $token" -L "https://github.com/NapNeko/NapCatQQ/releases/download/v1.1.1/$artifact_name.zip" -o "$output_dir/NapCat.linux.zip"
ls
echo "编译产物已保存到$output_dir/NapCat.linux.zip"
