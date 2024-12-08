#!/usr/bin/env bash

mkdir -p /share/ariang

# Add symlink to /aria2/data from /share/araiang
if [ ! -L /aria2/data ]; then
    ln -s /share/ariang /aria2/data
fi

# Run aria2
/aria2/start.sh "$@"