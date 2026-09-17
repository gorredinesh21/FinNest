# FinNest — single container: React build served from filesystem + Spring Boot API (H2 demo).
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
WORKDIR /app
COPY --from=api /build/target/*.jar app.jar
COPY --from=web /web/build ./web
# Rename static/ to assets/ to avoid Spring Boot's default /static/ handler conflict
RUN cd web && mv static assets 2>/dev/null; \
    find . -name "*.html" -exec sed -i 's|/static/|/assets/|g' {} +; \
    find assets -name "*.js" -exec sed -i 's|/static/|/assets/|g' {} + 2>/dev/null; \
    find assets -name "*.css" -exec sed -i 's|/static/|/assets/|g' {} + 2>/dev/null; true
ENV PORT=8080
# Tell Spring Boot to serve the SPA from the filesystem
ENV SPRING_WEB_RESOURCES_STATIC_LOCATIONS=file:/app/web/
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
