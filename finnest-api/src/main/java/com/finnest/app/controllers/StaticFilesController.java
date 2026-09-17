package com.finnest.app.controllers;

import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;

/**
 * Directly serves the React build's static files from the filesystem.
 * This bypasses Spring's resource chain entirely — the simplest thing
 * that reliably works in containers.
 */
@RestController
public class StaticFilesController {

    private static final Path WEB_DIR = Paths.get("/app/web");
    private static final Map<String, String> MIME = Map.of(
        ".js", "application/javascript",
        ".css", "text/css",
        ".html", "text/html",
        ".json", "application/json",
        ".png", "image/png",
        ".ico", "image/x-icon",
        ".svg", "image/svg+xml",
        ".woff", "font/woff",
        ".woff2", "font/woff2",
        ".map", "application/json"
    );

    @GetMapping("/static/**")
    public ResponseEntity<Resource> serveStatic(jakarta.servlet.http.HttpServletRequest request) {
        String path = request.getRequestURI();
        return serveFile(path);
    }

    @GetMapping("/{filename:.+}")
    public ResponseEntity<Resource> serveRootFile(@org.springframework.web.bind.annotation.PathVariable String filename) {
        if (filename.startsWith("api")) return ResponseEntity.notFound().build();
        return serveFile("/" + filename);
    }

    private ResponseEntity<Resource> serveFile(String uri) {
        Path file = WEB_DIR.resolve(uri.substring(1)).normalize();

        // Security: prevent path traversal
        if (!file.startsWith(WEB_DIR)) {
            return ResponseEntity.badRequest().build();
        }

        if (Files.exists(file) && Files.isRegularFile(file)) {
            String ext = uri.contains(".")
                ? uri.substring(uri.lastIndexOf('.')).toLowerCase()
                : "";
            String contentType = MIME.getOrDefault(ext, "application/octet-stream");

            return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, contentType)
                .header(HttpHeaders.CACHE_CONTROL, "public, max-age=3600")
                .body(new FileSystemResource(file));
        }

        return ResponseEntity.notFound().build();
    }
}
