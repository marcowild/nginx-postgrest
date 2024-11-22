#!/bin/bash

# Check for SSL certificates
if [ -f /keystore/tls.crt ] && [ -f /keystore/tls.key ]; then
    echo "SSL certificates found. Starting Nginx in HTTPS mode..."
else
    echo "No SSL certificates provided. Starting Nginx in HTTP mode..."
    # Remove SSL-related lines from Nginx configuration to avoid errors
    sed -i '/listen 8443 ssl/d' /etc/nginx/nginx.conf
    sed -i '/ssl_certificate/d' /etc/nginx/nginx.conf
    sed -i '/ssl_certificate_key/d' /etc/nginx/nginx.conf
fi

# Start PostgREST in the background
echo "Starting PostgREST..."
/usr/local/bin/postgrest /etc/postgrest/postgrest.conf &

# Start Nginx in the foreground
echo "Starting Nginx..."
nginx -g "daemon off;" &

# Start Prometheus Exporter in the background
echo "Starting Nginx Prometheus Exporter..."
/usr/local/bin/nginx-prometheus-exporter -nginx.scrape-uri=http://127.0.0.1:80/stub_status &

# Wait for all background processes to finish
wait -n

# Exit with the status of the first process that exited
exit $?
