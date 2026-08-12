const http = require('http');
const fs = require('fs');
const path = require('path');
const root = __dirname;
const port = process.argv[2] || 5173;
const mime = { '.html':'text/html; charset=utf-8', '.json':'application/json; charset=utf-8', '.js':'text/javascript; charset=utf-8', '.css':'text/css; charset=utf-8', '.svg':'image/svg+xml', '.png':'image/png', '.jpg':'image/jpeg', '.jpeg':'image/jpeg', '.webp':'image/webp', '.mp4':'video/mp4', '.ico':'image/x-icon' };
http.createServer((req, res) => {
  if (req.method === 'POST' && req.url === '/__api/save') {
    let body = '';
    req.on('data', c => body += c);
    req.on('end', () => {
      try {
        JSON.parse(body);
        fs.writeFileSync(path.join(root, 'data', 'portfolio.json'), body);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end('{"ok":true}');
      } catch (e) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end('{"ok":false}');
      }
    });
    return;
  }
  if (req.method === 'GET' && req.url === '/__api/ping') { res.writeHead(200, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' }); res.end('{"ok":true}'); return; }
  const urlPath = decodeURIComponent(req.url.split('?')[0]);
  let p = path.join(root, urlPath === '/' ? 'index.html' : urlPath);
  if (!p.startsWith(root)) { res.writeHead(403); res.end(); return; }
  fs.readFile(p, (err, data) => {
    if (err) { res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8', 'Cache-Control': 'no-store' }); res.end('404 - no encontrado: ' + urlPath); return; }
    res.writeHead(200, { 'Content-Type': mime[path.extname(p)] || 'application/octet-stream', 'Cache-Control': 'no-store' });
    res.end(data);
  });
}).listen(port, () => console.log('Estudio Prisma corriendo en http://localhost:' + port));