#!/bin/sh

set -e

echo "🔧 正在准备构建环境..."

# === 变量定义 ===
APP_NAME="alist"
ALIST_VERSION="v2.6.4"
BUILD_DIR="alist-${ALIST_VERSION}"
WEB_DIST_URL="https://github.com/alist-org/web-v2/releases/download/${ALIST_VERSION}/dist.tar.gz"
BUILT_AT="$(date +'%F %T %z')"
GO_VERSION=$(go version | sed 's/go version //')
WORK_DIR=$(pwd)

# === 下载 AList 源码 ===
if [ ! -d "$BUILD_DIR" ]; then
  echo "⬇️ 下载 AList 源码..."
  curl -L "https://github.com/Xhofe/alist/archive/refs/tags/${ALIST_VERSION}.tar.gz" -o "${ALIST_VERSION}.tar.gz"
  tar -xzf "${ALIST_VERSION}.tar.gz"
  mv "alist-${ALIST_VERSION}" "$BUILD_DIR"
fi

cd "$BUILD_DIR"

# === 准备前端页面 ===
mkdir -p public
echo "🌐 下载前端页面..."
curl -L "${WEB_DIST_URL}" -o dist.tar.gz
tar -xzf dist.tar.gz
mv dist/* public/
rm -rf dist dist.tar.gz

# === 构建 alist_freebsd 可执行文件 ===
echo "⚙️ 构建后端..."
cat <<EOF > build_freebsd.sh
#!/bin/sh
ldflags="\
-w -s \
-X 'github.com/Xhofe/alist/conf.BuiltAt=${BUILT_AT}' \
-X 'github.com/Xhofe/alist/conf.GoVersion=${GO_VERSION}' \
-X 'github.com/Xhofe/alist/conf.GitAuthor=AList Custom Build' \
-X 'github.com/Xhofe/alist/conf.GitCommit=manual' \
-X 'github.com/Xhofe/alist/conf.GitTag=${ALIST_VERSION}' \
-X 'github.com/Xhofe/alist/conf.WebTag=${ALIST_VERSION}' \
"
GOOS=freebsd GOARCH=amd64 go build -ldflags="\$ldflags" -tags=jsoniter -o alist ./alist.go
EOF

chmod +x build_freebsd.sh
./build_freebsd.sh

# === 配置运行目录 ===
echo "📁 设置运行目录结构..."
mkdir -p data
cat <<EOF > data/config.json
{
  "force": false,
  "address": "0.0.0.0",
  "port": 10086,  //改为自己面板中开放的TCP端口号
  "assets": "/",
  "local_assets": "./public",
  "sub_folder": "",
  "database": {
    "type": "sqlite3",
    "db_file": "data/data.db",
    "table_prefix": "x_"
  },
  "scheme": {
    "https": false
  },
  "cache": {
    "expiration": 60,
    "cleanup_interval": 120
  },
  "temp_dir": "data/temp"
}
EOF

# === 运行 alist ===
echo "🚀 启动 AList..."
./alist
