package com.finnest.app;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.resource.PathResourceResolver;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Serves the React SPA from /app/web/ (container deploy) or classpath:/static/.
 * API routes mapped by controllers are unaffected (they register first).
 */
@Configuration
public class SpaConfig implements WebMvcConfigurer {
    private static final Path WEB_DIR = Paths.get("/app/web");

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String location;
        if (Files.exists(WEB_DIR.resolve("index.html"))) {
            location = "file:" + WEB_DIR + "/";
        } else {
            location = "classpath:/static/";
        }

        registry.addResourceHandler("/static/**", "/favicon.ico", "/manifest.json",
                        "/logo*.png", "/apple-touch-icon*.png")
                .addResourceLocations(location)
                .resourceChain(true)
                .addResolver(new PathResourceResolver());

        // SPA fallback for client-side routes (but NOT for /api/** which is
        // handled by controllers)
        registry.addResourceHandler("/**")
                .addResourceLocations(location)
                .resourceChain(true)
                .addResolver(new PathResourceResolver() {
                    @Override
                    protected org.springframework.core.io.Resource getResource(
                            String resourcePath,
                            org.springframework.core.io.Resource location1) throws java.io.IOException {
                        org.springframework.core.io.Resource requested = location1.createRelative(resourcePath);
                        if (requested.exists() && requested.isReadable()) {
                            return requested;
                        }
                        if (resourcePath.startsWith("api/")) {
                            return null; // let controllers handle it
                        }
                        // SPA fallback
                        org.springframework.core.io.Resource index = location1.createRelative("index.html");
                        return index.exists() ? index : null;
                    }
                });
    }
}
