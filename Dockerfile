# FinNest — nginx serves the React SPA, proxies /api to Spring Boot
FROM node:20-slim AS web
WORKDIR /web
COPY finnest-web/package.json finnest-web/package-lock.json ./
RUN npm ci --no-fund --no-audit
COPY finnest-web/ ./
RUN npm run build

FROM maven:3.9-eclipse-temurin-17 AS api
WORKDIR /build
COPY finnest-api/pom.xml .
RUN mvn -q dependency:go-offline
COPY finnest-api/src ./src
RUN mvn -q package -DskipTests

FROM eclipse-temurin:17-jre-alpine
RUN apk add --no-cache nginx
WORKDIR /app
COPY --from=api /build/target/*.jar app.jar
COPY --from=web /web/build ./web

# nginx config: serve SPA, proxy API
RUN cat > /etc/nginx/http.d/default.conf <<'NGINX'
server {
    listen 8080;
    location /api/ {
        proxy_pass http://127.0.0.1:8070;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    location / {
        root /app/web;
        try_files $uri /index.html;
    }
}
NGINX

# startup: Spring Boot on 8070, nginx on 8080
RUN cat > /start.sh <<'SHELL'
#!/bin/sh
java -jar app.jar --server.port=8070 --server.address=127.0.0.1 &
nginx -g 'daemon off;'
SHELL
RUN chmod +x /start.sh

EXPOSE 8080
ENTRYPOINT ["/start.sh"]
