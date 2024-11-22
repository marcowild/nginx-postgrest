# Stage 1: Pull and extract postgrest binary
FROM postgrest/postgrest:v12.2.3 AS base

# Runtime image
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    nginx-extras \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user with UID 1000
RUN useradd -u 1000 -m -s /bin/bash nonroot

# Set up nginx-prometheus-exporter
COPY nginx-prometheus-exporter /usr/local/bin/nginx-prometheus-exporter
RUN chmod +x /usr/local/bin/nginx-prometheus-exporter

# Copy PostgREST binary and configuration
COPY --from=base /bin/postgrest /usr/local/bin/postgrest
COPY postgrest.conf /etc/postgrest/postgrest.conf
RUN chown -R nonroot:nonroot /usr/local/bin/postgrest /etc/postgrest

RUN mkdir -p /var/lib/nginx /var/log/nginx && \
    chown -R nonroot:nonroot /var/lib/nginx /var/log/nginx && \
    chmod -R g+w /var/lib/nginx /var/log/nginx

COPY nginx.conf /etc/nginx/nginx.conf
RUN chown -R nonroot:nonroot /etc/nginx

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && chown nonroot:nonroot /usr/local/bin/entrypoint.sh

EXPOSE 8080 8443 9113

# Switch to non-root user
USER nonroot

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
