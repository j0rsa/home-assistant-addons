#!/usr/bin/with-contenv bashio

bashio::log.info "Starting Xray Configurator web interface..."

# Ensure nginx directories exist
mkdir -p /var/log/nginx
mkdir -p /var/lib/nginx/tmp
mkdir -p /run/nginx

# Set proper permissions
chown -R nginx:nginx /var/log/nginx
chown -R nginx:nginx /var/lib/nginx
chown -R nginx:nginx /run/nginx
chown -R nginx:nginx /var/www/html

bashio::log.info "Web interface will be available on port 8099"
bashio::log.info "Configuration converter ready to use"

# Start nginx in foreground
exec nginx -g "daemon off;"