#!/usr/bin/with-contenv bashio

PASSWORD=$(bashio::config 'password')
SETTINGS_ENCRYPTION_KEY=$(bashio::config 'settings_encryption_key')

mkdir -p /run/duplicati-temp

if [[ -f "/config/Duplicati-server.sqlite" ]]; then
    # Existing install
    if [[ -n ${SETTINGS_ENCRYPTION_KEY} ]]; then
        # Enable settings encryption
        true
    else
        # Disable settings encryption
        printf "true" > /run/s6/container_environment/DUPLICATI__DISABLE_DB_ENCRYPTION
        echo "***      Missing encryption key, unable to encrypt your settings database     ***"
        echo "*** Please set a value for SETTINGS_ENCRYPTION_KEY and recreate the container ***"
    fi
else
    # New install
    if [[ -z ${PASSWORD} ]]; then
        true
    fi
    if [[ -n ${SETTINGS_ENCRYPTION_KEY} ]]; then
        # Enable settings encryption
        true
    else
        # Halt init
        echo "***      Missing encryption key, unable to encrypt your settings database     ***"
        echo "*** Please set a value for SETTINGS_ENCRYPTION_KEY and recreate the container ***"
        sleep infinity
    fi
fi

# Pass as environment variable or CLI argument
./duplicati-server --webservice-password="$PASSWORD" --settings-encryption-key="$SETTINGS_ENCRYPTION_KEY"
