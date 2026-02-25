#!/usr/bin/with-contenv bashio

export WEBDAV_USER=$(bashio::config 'webdav_user')
export WEBDAV_PASS=$(bashio::config 'webdav_password')
export MEDIA_URL=$(bashio::config 'media_url')
export PORT=8099
export COURSES_JSON=/share/course-watch/courses.json

bashio::log.info "Starting Course Watch..."

if bashio::config.has_value 'webdav_user'; then
    bashio::log.info "WebDAV auth enabled for user: ${WEBDAV_USER}"
else
    bashio::log.warning "No WebDAV credentials configured — proxy will send unauthenticated requests"
fi

bashio::log.info "Courses file: ${COURSES_JSON}"
bashio::log.info "Web UI available on port ${PORT}"

mkdir -p /share/course-watch

exec python3 /app/server.py
