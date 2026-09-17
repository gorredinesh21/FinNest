# FinNest — single container: React web build + Spring Boot API (H2 demo mode).
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
COPY --from=web /web/build/ ./target/classes/static/
RUN mvn -q package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=api /build/target/*.jar app.jar
COPY --from=web /web/build/ ./target/classes/static/
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
