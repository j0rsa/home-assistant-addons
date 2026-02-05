ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-debian:bookworm

FROM ${BUILD_FROM}

ARG BUILD_VERSION
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG HEV_VERSION=2.10.1

RUN echo "**** Building $BUILD_ARCH:$BUILD_VERSION image ****" && \
    echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y \
      ca-certificates \
      curl \
      iptables \
      iproute2 && \
    echo "**** download hev-socks5-tproxy binary ****" && \
    ARCH_SUFFIX="" && \
    if [ "$BUILD_ARCH" = "amd64" ]; then ARCH_SUFFIX="x86_64"; fi && \
    if [ "$BUILD_ARCH" = "aarch64" ]; then ARCH_SUFFIX="arm64"; fi && \
    curl -fSL "https://github.com/heiher/hev-socks5-tproxy/releases/download/${HEV_VERSION}/hev-socks5-tproxy-linux-${ARCH_SUFFIX}" \
      -o /usr/local/bin/hev-socks5-tproxy && \
    chmod +x /usr/local/bin/hev-socks5-tproxy && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]

LABEL \
  io.hass.version=${BUILD_VERSION} \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.created=${BUILD_DATE} \
  org.opencontainers.image.revision=${BUILD_REF} \
  org.opencontainers.image.version=${BUILD_VERSION}
