# global arg that is outside of any FROM clause
ARG BUILD_FROM=ghcr.io/hassio-addons/amd64-base-ubuntu:20.04

# https://github.com/linuxserver/docker-duplicati
# https://github.com/linuxserver/docker-duplicati/pkgs/container/duplicati
# FROM ghcr.io/linuxserver/duplicati:v2.1.0.5_stable_2025-03-04-ls251 as source

FROM ${BUILD_FROM}

ARG BUILD_VERSION
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF

ENV HOME="/config" \
  TMPDIR=/run/duplicati-temp \
  DUPLICATI__REQUIRE_DB_ENCRYPTION_KEY=true \
  DUPLICATI__SERVER_DATAFOLDER=/config \
  DUPLICATI__WEBSERVICE_PORT=8200 \
  DUPLICATI__WEBSERVICE_INTERFACE=any \
  DUPLICATI__WEBSERVICE_ALLOWED_HOSTNAMES=*

RUN echo "**** Building $BUILD_ARCH:$BUILD_VERSION image ****" && \
    mkdir -p /run/duplicati-temp && \
    echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y \
      libicu66 \
      unzip \
      xz-utils && \
    echo "**** install duplicati ****" && \
    if [ -z ${DUPLICATI_RELEASE+x} ]; then \
      DUPLICATI_RELEASE=$(curl -sX GET "https://api.github.com/repos/duplicati/duplicati/releases/latest" | jq -r .tag_name); \
    fi && \
    echo "Using Duplicati release: ${DUPLICATI_RELEASE}" && \
    if [ "$BUILD_ARCH" = "amd64" ]; then \
      duplicati_url=$(curl -s "https://api.github.com/repos/duplicati/duplicati/releases/tags/${DUPLICATI_RELEASE}" | jq -r '.assets[].browser_download_url' | grep "linux-x64-gui.zip$"); \
    elif [ "$BUILD_ARCH" = "aarch64" ]; then \
      duplicati_url=$(curl -s "https://api.github.com/repos/duplicati/duplicati/releases/tags/${DUPLICATI_RELEASE}" | jq -r '.assets[].browser_download_url' | grep "linux-arm64-gui.zip$"); \
    else \
      echo "Unsupported arch '$BUILD_ARCH'" && \
      exit 255; \
    fi && \
    curl -o /tmp/duplicati.zip -L "${duplicati_url}" && \
    unzip -q /tmp/duplicati.zip -d /app && \
    mv /app/duplicati* /app/duplicati && \
    printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

WORKDIR /app/duplicati

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