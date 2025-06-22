#!/bin/sh

# 设置 GOPATH
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# 安装 go 和 git（如未安装）
pkg install -y go git wget curl

# 拉取源码
if [ ! -d "alist-src" ]; then
    git clone https://github.com/alist-org/alist.git alist-src
    cd alist-src
    git checkout v2.6.4
else
    cd alist-src
    git checkout v2.6.4
fi

# 编译 FreeBSD amd64 可执行文件
GOOS=freebsd GOARCH=amd64 go build -o alist

# 检查并打包
if [ -f "alist" ]; then
    tar -czf alist-freebsd-amd64.tar.gz alist
    cd ..
    mkdir -p public_nodejs
    cp alist-src/alist public_nodejs/web.js
    cp alist-src/alist-freebsd-amd64.tar.gz public_nodejs/
    chmod +x public_nodejs/web.js
    echo "✅ AList v2.6.4 编译完成并部署至 public_nodejs/"
else
    echo "❌ 构建失败"
fi
