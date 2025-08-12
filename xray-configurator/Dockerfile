ARG BUILD_FROM
FROM $BUILD_FROM

# Install nginx
RUN apk add --no-cache \
    nginx \
    bash \
    s6-overlay \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/lib/nginx/tmp \
    && mkdir -p /run/nginx

# Create web directory
RUN mkdir -p /var/www/html

# Copy web files
COPY www/ /var/www/html/
COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /
RUN chmod a+x /run.sh

# Set permissions for nginx directories
RUN chown -R nginx:nginx /var/www/html \
    && chown -R nginx:nginx /var/log/nginx \
    && chown -R nginx:nginx /var/lib/nginx \
    && chown -R nginx:nginx /run/nginx

CMD [ "/run.sh" ]