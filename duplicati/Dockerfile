# https://github.com/linuxserver/docker-duplicati
# https://github.com/linuxserver/docker-duplicati/pkgs/container/duplicati
FROM ghcr.io/linuxserver/duplicati:v2.1.0.5_stable_2025-03-04-ls251

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