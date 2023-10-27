FROM alpine:3.18.4

RUN apk add --no-cache sniproxy

COPY sniproxy.conf /
COPY run.sh /
RUN chmod a+x /run.sh

ENTRYPOINT /run.sh

LABEL \
  io.hass.version="0.0.3" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|armv7|amd64"