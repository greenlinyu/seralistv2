#!/bin/sh

echo "开始部署 AList v2.6.4（FreeBSD）..."
chmod +x start.sh
chmod +x web.js 2>/dev/null

# 安装 Node 依赖
if ! [ -d "node_modules" ]; then
    echo "安装 Node 模块依赖..."
    npm install
fi

# 启动反代服务
echo "启动 Node.js 反向代理..."
nohup node app.js > /dev/null 2>&1 &

# 启动 AList 后端
echo "启动 AList 后端..."
./start.sh
