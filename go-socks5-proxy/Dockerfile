ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-ubuntu:20.04

# Use multi-stage build to get the binary from official image
FROM serjs/go-socks5-proxy:v0.0.4 AS socks5-source

FROM ${BUILD_FROM}

ARG BUILD_VERSION
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF

RUN echo "**** Building $BUILD_ARCH:$BUILD_VERSION image ****" && \
    echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y \
      ca-certificates && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Copy the socks5 binary from the official image
COPY --from=socks5-source /app/go-socks5-proxy /usr/local/bin/go-socks5-proxy
RUN chmod +x /usr/local/bin/go-socks5-proxy

COPY run.sh /
RUN chmod a+x /run.sh

EXPOSE 1080

CMD ["/run.sh"]

LABEL \
  io.hass.version=${BUILD_VERSION} \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.created=${BUILD_DATE} \
  org.opencontainers.image.revision=${BUILD_REF} \
  org.opencontainers.image.version=${BUILD_VERSION}
