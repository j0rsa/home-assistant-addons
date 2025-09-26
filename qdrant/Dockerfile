ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-ubuntu:20.04

FROM ${BUILD_FROM}

ARG BUILD_VERSION
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF

RUN echo "**** Building $BUILD_ARCH:$BUILD_VERSION image ****" && \
    echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y \
      curl \
      ca-certificates \
      gosu && \
    echo "**** install qdrant ****" && \
    QDRANT_VERSION=$(curl -s "https://api.github.com/repos/qdrant/qdrant/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")') && \
    echo "Using Qdrant version: ${QDRANT_VERSION}" && \
    if [ "$BUILD_ARCH" = "amd64" ]; then \
      QDRANT_ARCH="x86_64"; \
    elif [ "$BUILD_ARCH" = "aarch64" ]; then \
      QDRANT_ARCH="aarch64"; \
    elif [ "$BUILD_ARCH" = "armv7" ]; then \
      QDRANT_ARCH="armv7"; \
    else \
      echo "Unsupported arch '$BUILD_ARCH'" && \
      exit 255; \
    fi && \
    echo "**** installing qdrant for ${QDRANT_ARCH} ****" && \
    curl -L "https://github.com/qdrant/qdrant/releases/download/${QDRANT_VERSION}/qdrant-${QDRANT_ARCH}-unknown-linux-musl.tar.gz" -o /tmp/qdrant.tar.gz && \
    echo "**** extracting qdrant ****" && \
    mkdir -p /tmp/qdrant && \
    tar -xzf /tmp/qdrant.tar.gz -C /tmp/qdrant && \
    echo "**** listing extracted contents ****" && \
    find /tmp/qdrant -name "qdrant" -type f && \
    cp $(find /tmp/qdrant -name "qdrant" -type f | head -1) /usr/local/bin/qdrant && \
    chmod +x /usr/local/bin/qdrant && \
    echo "**** create qdrant user and directories ****" && \
    groupadd -r qdrant && \
    useradd -r -g qdrant -d /var/lib/qdrant -s /sbin/nologin qdrant && \
    mkdir -p /var/lib/qdrant /var/log/qdrant && \
    chown -R qdrant:qdrant /var/lib/qdrant /var/log/qdrant && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY run.sh /
RUN chmod a+x /run.sh

EXPOSE 6333 6334

CMD ["/run.sh"]

LABEL \
  io.hass.version=${BUILD_VERSION} \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.created=${BUILD_DATE} \
  org.opencontainers.image.revision=${BUILD_REF} \
  org.opencontainers.image.version=${BUILD_VERSION}