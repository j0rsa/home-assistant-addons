#!/usr/bin/env bash

# If /root/.ollama exists and is not a symbolic link, remove it
if [ -e /root/.ollama ] && [ ! -L /root/.ollama ]; then
    rm -rf /root/.ollama
fi

# Add symlink to /root/.ollama from /share/ollama
if [ ! -L /root/.ollama ]; then
    ln -s /share/ollama /root/.ollama
fi

# Run ollama
/bin/ollama "$@"