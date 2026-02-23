ARG UPSTREAM_IMAGE=docker.litellm.ai/berriai/litellm:v1.81.12-stable
ARG BUILD_FROM=ghcr.io/hassio-addons/ubuntu-base/amd64:11.0.0

FROM ${UPSTREAM_IMAGE} AS upstream

# Bundle all runtime artifacts; resolves the versioned Python lib path dynamically
# to avoid hardcoding the Python version (Wolfi installs packages to /usr/lib/python3.x/)
RUN PY_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')") && \
    tar -cf /upstream-payload.tar \
        /usr/local \
        /usr/bin/python3 \
        /usr/bin/python${PY_VER} \
        /usr/bin/litellm \
        /usr/lib/python${PY_VER} \
        /usr/lib/libpython${PY_VER}.so.1.0 \
        /usr/lib/libcrypto.so.3 \
        /usr/lib/libssl.so.3 \
        /usr/lib/libgcc_s.so.1 \
        /usr/bin/node \
        /usr/lib/node_modules \
        /app

FROM ${BUILD_FROM}

ARG BUILD_VERSION
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF

# Install system runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        jq \
        libssl3 \
        libffi8 \
        libsndfile1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Extract Python, Node.js, and litellm from upstream image.
# Override Ubuntu's OpenSSL 3.0 with the upstream's OpenSSL 3.6 that Python was compiled against.
COPY --from=upstream /upstream-payload.tar /tmp/
RUN ARCH_LIB=/usr/lib/$(uname -m)-linux-gnu && \
    tar xf /tmp/upstream-payload.tar -C / && \
    cp -f /usr/lib/libcrypto.so.3 "${ARCH_LIB}/libcrypto.so.3" && \
    cp -f /usr/lib/libssl.so.3 "${ARCH_LIB}/libssl.so.3" && \
    cp -f /usr/lib/libgcc_s.so.1 "${ARCH_LIB}/libgcc_s.so.1" && \
    ldconfig && \
    rm /tmp/upstream-payload.tar

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
