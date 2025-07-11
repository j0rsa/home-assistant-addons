#!/usr/bin/with-contenv bashio

PASSWORD=$(bashio::config 'password')

# Pass as environment variable or CLI argument
exec duplicati-server --webservice-password="$PASSWORD"
