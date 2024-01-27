#!/usr/bin/env bash

mkdir -p /share/ollama-ui

# If /app/backend/data exists and is not a symbolic link, remove it
if [ -e /app/backend/data ] && [ ! -L /app/backend/data ]; then
    rm -rf /app/backend/data
fi

# Add symlink to /app/backend/data from /share/ollama
if [ ! -L /app/backend/data ]; then
    ln -s /share/ollama-ui /app/backend/data
fi

# Run ollama
start.sh