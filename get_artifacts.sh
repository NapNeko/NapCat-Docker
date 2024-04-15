#!/bin/bash

# 设置仓库信息
repository="NapNeko/NapCat.Build"
arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/x64/)
artifact_name="NapCat.linux.$arch"
token="$1"

# 设置输出目录
output_dir="."

# 下载release
curl -s -X GET -H "Authorization: token $token" -L "https://github.com/NapNeko/NapCatQQ/releases/download/v1.0.2/NapCat.linux.$arch.zip" -o "$output_dir/NapCat.linux.zip"

echo "编译产物已保存到$output_dir/NapCat.linux.zip"
