FROM node:20-slim
WORKDIR /web
COPY finnest-web/package.json finnest-web/package-lock.json ./
RUN npm ci --no-fund --no-audit
COPY finnest-web/ ./
RUN npm run build

FROM python:3.12-slim
WORKDIR /app
COPY --from=web /web/build ./web
ENV PORT=8080
CMD exec python -m http.server ${PORT} --directory /app/web
