ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-ubuntu:20.04

FROM ${BUILD_FROM}

ARG BUILD_VERSION
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF

RUN echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      sniproxy \
      proxychains4 \
      ca-certificates && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Copy sniproxy configuration
COPY sniproxy.conf /etc/sniproxy/sniproxy.conf

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set working directory
WORKDIR /etc/sniproxy

CMD ["/run.sh"]

LABEL \
  io.hass.version=${BUILD_VERSION} \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.title="SNI Socket Proxy Home Assistant add-on" \
  org.opencontainers.image.description="SNI proxy with SOCKS5 proxy support" \
  org.opencontainers.image.created=${BUILD_DATE} \
  org.opencontainers.image.revision=${BUILD_REF} \
  org.opencontainers.image.version=${BUILD_VERSION}
