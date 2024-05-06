#!/bin/bash

token="$1"
version="$2"

# 设置输出目录
output_dir="."
# 下载release
curl -s -X GET \
    -H "Authorization: token $token" \
    -L "https://github.com/NapNeko/NapCatQQ/releases/download/$version/NapCat.linux.x64.zip" \
    -o "$output_dir/NapCat.linux.x64.zip"

curl -s -X GET \
    -H "Authorization: token $token" \
    -L "https://github.com/NapNeko/NapCatQQ/releases/download/$version/NapCat.linux.arm64.zip" \
    -o "$output_dir/NapCat.linux.arm64.zip"

echo "编译产物已保存到$output_dir"
ls -lh
