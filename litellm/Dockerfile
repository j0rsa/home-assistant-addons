ARG UPSTREAM_IMAGE=docker.litellm.ai/berriai/litellm:main-stable
ARG BUILD_FROM=ghcr.io/hassio-addons/ubuntu-base/amd64:11.0.0

FROM ${UPSTREAM_IMAGE} AS upstream

FROM ${BUILD_FROM}

ARG BUILD_VERSION
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF

# Copy Python environment and litellm from upstream image
COPY --from=upstream /usr/local /usr/local

# Install system runtime dependencies and jq
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        jq \
        libssl3 \
        libffi8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
