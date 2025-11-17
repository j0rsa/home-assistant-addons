ARG BUILD_FROM=ghcr.io/raylabshq/gitea-mirror:v3.9.2

FROM ${BUILD_FROM}

USER root

RUN apk add --no-cache bash jq su-exec coreutils

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]

ARG BUILD_VERSION
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF

LABEL \
  io.hass.version=${BUILD_VERSION} \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.licenses="AGPL-3.0" \
  org.opencontainers.image.title="Gitea Mirror Home Assistant add-on" \
  org.opencontainers.image.description="Mirror GitHub repositories into Gitea via Home Assistant" \
  org.opencontainers.image.created=${BUILD_DATE} \
  org.opencontainers.image.revision=${BUILD_REF} \
  org.opencontainers.image.version=${BUILD_VERSION}
