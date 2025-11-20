# Multi-stage build: extract application from upstream image
ARG UPSTREAM_IMAGE=ghcr.io/raylabshq/gitea-mirror:v3.9.2
# Use HA Ubuntu base image with bashio (BUILD_FROM comes from build.yaml)
ARG BUILD_FROM

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

# Install bun (required by the application)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    unzip \
    ca-certificates \
    jq \
    netcat-openbsd && \
    curl -fsSL https://bun.sh/install | bash && \
    if [ ! -f /root/.bun/bin/bun ]; then \
        echo "ERROR: bun installation failed" && exit 1; \
    fi && \
    ln -sf /root/.bun/bin/bun /usr/local/bin/bun && \
    chmod +x /usr/local/bin/bun && \
    bun --version && \
    # Keep curl - bashio needs it to communicate with Supervisor API
    # Only remove unzip as it's not needed at runtime
    apt-get purge -y --auto-remove unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Ensure PATH includes /usr/local/bin where bun is installed
# This ensures PATH is available to all processes, including exec'd scripts
ENV PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Copy run script
COPY run.sh /app/ha-run.sh
RUN chmod +x /app/ha-run.sh

WORKDIR /app

CMD ["/app/ha-run.sh"]

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
