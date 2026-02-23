ARG BUILD_FROM=ghcr.io/hassio-addons/base-python:13.1.3

FROM ${BUILD_FROM}

# https://github.com/open-webui/open-webui/pkgs/container/open-webui/versions?filters%5Bversion_type%5D=tagged
FROM ghcr.io/open-webui/open-webui:v0.8.4

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

ARG BUILD_VERSION
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF

LABEL \
  io.hass.version=${BUILD_VERSION} \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.created=${BUILD_DATE} \
  org.opencontainers.image.revision=${BUILD_REF} \
  org.opencontainers.image.version=${BUILD_VERSION}