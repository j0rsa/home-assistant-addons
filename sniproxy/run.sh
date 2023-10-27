#!/usr/bin/env bash
echo "Starting Add-on"
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "Add-on IP Address is: $IP_ADDRESS"

sniproxy -c /sniproxy.conf -f