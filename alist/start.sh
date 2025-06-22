#!/bin/sh

SCRIPT_PATH=$(realpath "$0")
WORKDIR=$(dirname "${SCRIPT_PATH}")
cd "${WORKDIR}"
FILES_PATH=${FILES_PATH:-./}

if [ ! -f "./web.js" ]; then
  echo "❌ web.js 不存在，请先执行 install_2.6.4.sh 编译并部署。"
  exit 1
fi

echo "🚀 正在启动 AList v2.6.4..."
chmod +x ./web.js
exec ./web.js server > /dev/null 2>&1 &
