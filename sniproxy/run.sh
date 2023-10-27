#!/usr/bin/env sh
echo "Starting Add-on"
IP_ADDRESS=$(hostname -i | awk '{print $1}')
echo "Add-on IP Address is: $IP_ADDRESS"

sniproxy -c /sniproxy.conf -f