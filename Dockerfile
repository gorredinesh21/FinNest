# FinNest — split deploy: this service serves the React frontend.
# The Spring Boot API runs separately; the frontend calls it via fetch.
FROM node:20-slim AS web
WORKDIR /web
COPY finnest-web/package.json finnest-web/package-lock.json ./
RUN npm ci --no-fund --no-audit
COPY finnest-web/ ./
RUN npm run build

FROM python:3.12-slim
WORKDIR /app
COPY --from=web /web/build ./web
RUN cat > serve.py <<'PY'
import http.server, os, sys, urllib.request
from functools import partial

API = os.environ.get("API_URL", "http://localhost:8070")
PORT = int(os.environ.get("PORT", "8080"))

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kw):
        super().__init__(*args, directory="/app/web", **kw)
    def do_PROXY(self, method):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length) if length else None
        req = urllib.request.Request(API + self.path.replace("/api", "", 1), data=body, method=method)
        for h in ["Content-Type", "Authorization"]:
            if h in self.headers: req.add_header(h, self.headers[h])
        try:
            resp = urllib.request.urlopen(req)
            self.send_response(resp.status)
            for k, v in resp.headers.items():
                if k.lower() not in ("transfer-encoding",): self.send_header(k, v)
            self.end_headers()
            self.wfile.write(resp.read())
        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self.end_headers()
            self.wfile.write(e.read())
    def do_GET(self):
        if self.path.startswith("/api/"): self.do_PROXY("GET"); return
        super().do_GET()
    def do_POST(self):
        if self.path.startswith("/api/"): self.do_PROXY("POST"); return
        self.send_error(405)

print(f"FinNest frontend on :{PORT} (API proxy -> {API})")
http.server.HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
PY
ENV PORT=8080
ENV API_URL=http://localhost:8070
CMD exec python serve.py
