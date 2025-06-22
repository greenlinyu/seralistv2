const express = require("express");
const app = express();
const port = 3000;
var exec = require("child_process").exec;
const { createProxyMiddleware } = require("http-proxy-middleware");

app.use('/', createProxyMiddleware({
  target: 'http://127.0.0.1:port',
  changeOrigin: true,
  ws: true,
  onError: (err, req, res) => {
    res.writeHead(500, {
      'Content-Type': 'text/plain',
    });
    res.end('请稍等片刻后刷新页面');
  },
}));

function keep_web_alive() {
  exec("pgrep -laf web.js", function (err, stdout, stderr) {
    if (stdout.includes("web.js server")) {
      console.log("web 正在运行");
    } else {
      exec(
        "bash start.sh > /dev/null 2>&1 &",
        function (err, stdout, stderr) {
          if (err) {
            console.log("保活失败:" + err);
          } else {
            console.log("保活：重新启动 web.js 成功！");
          }
        }
      );
    }
  });
}
setInterval(keep_web_alive, 10 * 1000);

app.listen(port, () => console.log(`AList v2 反代服务启动于 ${port}`));
