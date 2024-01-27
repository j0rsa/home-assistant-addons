#!/usr/bin/env bash

# add simlink to /root/.ollama from /share/ollama
if [ ! -L /root/.ollama ]; then
    ln -s /share/ollama /root/.ollama
fi

# run ollama
/bin/ollama "$@"