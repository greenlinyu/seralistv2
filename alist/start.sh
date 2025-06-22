#!/bin/sh

SCRIPT_PATH=$(realpath "$0")
WORKDIR=$(dirname "${SCRIPT_PATH}")
cd "${WORKDIR}"
FILES_PATH=${FILES_PATH:-./}
TMP_DIRECTORY="$(mktemp -d)"
ZIP_FILE="${TMP_DIRECTORY}/alist.tar.gz"
BIN_FILE="./web.js"

# 解压预编译的 alist 文件到 web.js（或已存在）
if [ ! -f "$BIN_FILE" ]; then
    echo "解压 alist 可执行文件..."
    tar -xzf "$ZIP_FILE" -C "$TMP_DIRECTORY"
    cp "${TMP_DIRECTORY}/alist" ./web.js
    chmod +x ./web.js
fi

# 启动
echo "启动 Alist..."
killall web.js 2>/dev/null
nohup ./web.js server > /dev/null 2>&1 &
rm -rf "$TMP_DIRECTORY"
