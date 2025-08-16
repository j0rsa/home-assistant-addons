ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-alpine:3.20

FROM ${BUILD_FROM}

ARG BUILD_VERSION
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF

RUN echo "**** Building $BUILD_ARCH:$BUILD_VERSION image ****" && \
    echo "**** install packages ****" && \
    apk add --no-cache \
      curl \
      jq \
      iproute2 \
      iptables \
      redsocks \
      wireguard-tools && \
    echo "**** install netclient ****" && \
    if [ "$BUILD_ARCH" = "amd64" ]; then \
      NETCLIENT_ARCH="amd64"; \
    elif [ "$BUILD_ARCH" = "aarch64" ]; then \
      NETCLIENT_ARCH="arm64"; \
    elif [ "$BUILD_ARCH" = "armv7" ]; then \
      NETCLIENT_ARCH="armv7"; \
    else \
      echo "Unsupported arch '$BUILD_ARCH'" && \
      exit 255; \
    fi && \
    curl -L "https://github.com/gravitl/netclient/releases/latest/download/netclient-linux-${NETCLIENT_ARCH}" -o /usr/local/bin/netclient && \
    chmod +x /usr/local/bin/netclient && \
    echo "**** install tun2socks ****" && \
    if [ "$BUILD_ARCH" = "amd64" ]; then \
      TUN2SOCKS_ARCH="amd64"; \
    elif [ "$BUILD_ARCH" = "aarch64" ]; then \
      TUN2SOCKS_ARCH="arm64"; \
    elif [ "$BUILD_ARCH" = "armv7" ]; then \
      TUN2SOCKS_ARCH="armv7"; \
    else \
      echo "Unsupported arch '$BUILD_ARCH'" && \
      exit 255; \
    fi && \
    curl -L "https://github.com/xjasonlyu/tun2socks/releases/latest/download/tun2socks_linux_${TUN2SOCKS_ARCH}" -o /usr/local/bin/tun2socks && \
    chmod +x /usr/local/bin/tun2socks && \
    echo "**** setup directories ****" && \
    mkdir -p /dev/net /var/lib/netclient && \
    echo "**** cleanup ****" && \
    rm -rf /tmp/* /var/cache/apk/*

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