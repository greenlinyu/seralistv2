const express = require("express");
const app = express();
const port = 3000;
var exec = require("child_process").exec;
const { createProxyMiddleware } = require("http-proxy-middleware");

app.use('/', createProxyMiddleware({
  target: 'http://127.0.0.1:port', // 修改为自己端口
  changeOrigin: true,
  ws: true,
  onError: (err, req, res) => {
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end('Alist 正在启动中，请稍候刷新。');
  },
}));

function keep_web_alive() {
  exec("pgrep -laf web.js", function (err, stdout, stderr) {
    if (!stdout.includes("web.js server")) {
      exec("bash start.sh", function (err) {
        if (err) console.log("启动失败:", err);
        else console.log("web.js 启动成功");
      });
    }
  });
}
setInterval(keep_web_alive, 10000);

app.listen(port, () => console.log(`反代服务运行在端口 ${port}`));
