FROM alpine:3.18.4

RUN apk add --no-cache sniproxy

COPY sniproxy.conf /
COPY run.sh /
RUN chmod a+x /run.sh

ENTRYPOINT /run.sh

ARG BUILD_VERSION
ARG BUILD_ARCH
LABEL \
  io.hass.version=${BUILD_VERSION} \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}"