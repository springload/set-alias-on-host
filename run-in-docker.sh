#!/usr/bin/env sh

if [ -z "${HOST_ALIAS}" ] ; then
    echo "Please set \"HOST_ALIAS\" environment variable to service alias you want to register"
    exit 1
fi

IFS=" ,";  # split host aliases by space or comma
for ALIAS in ${HOST_ALIAS}; do
    set-alias-on-host.sh "${HOST_FILE:-/host/etc/hosts}" ${ALIAS};
done;
