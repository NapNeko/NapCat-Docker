#!/bin/bash

token="$1"
version="$2"

# 设置输出目录
output_dir="."
# 下载release
curl -s -X GET \
    -H "Authorization: token $token" \
    -L "https://github.com/NapNeko/NapCatQQ/releases/download/$version/NapCat.Shell.zip" \
    -o "$output_dir/NapCat.Shell.zip"
# 下载packet-server
curl -s -X GET \
    -H "Authorization: token $token" \
    -L "https://github.com/NapNeko/NapCatQQ/releases/download/$version/napcat.packet.linux" \
    -o "$output_dir/napcat.packet.linux"

echo "编译产物已保存到$output_dir"
ls -lh
