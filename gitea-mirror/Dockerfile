# Multi-stage build: extract application from upstream image
ARG UPSTREAM_IMAGE=ghcr.io/raylabshq/gitea-mirror:v3.9.2
# Use HA Alpine base image with bashio (BUILD_FROM comes from build.yaml)
ARG BUILD_FROM=ghcr.io/home-assistant/base-alpine:3.20

FROM ${UPSTREAM_IMAGE} AS upstream

FROM ${BUILD_FROM}

ARG BUILD_VERSION
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF

# Copy application files from upstream image
COPY --from=upstream /app /app
# Try to copy gitea-mirror binary if it exists (may be in different locations)
RUN if [ -f /app/docker-entrypoint.sh ]; then chmod +x /app/docker-entrypoint.sh; fi || true

# Install any additional dependencies if needed
RUN apk add --no-cache \
    bash \
    coreutils

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

WORKDIR /app

CMD ["/run.sh"]

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
