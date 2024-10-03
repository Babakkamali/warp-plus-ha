#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

HOST="$3" # third parameter should be host ip
PORT="$4" # forth parameter should be host port

# Check if the SOCKS5 proxy is working
HTTP_CODE=$(curl -x socks5h://${HOST}:${PORT} -o /dev/null -s -w "%{http_code}" http://gstatic.com/generate_204)
if [ "$HTTP_CODE" != "204" ]; then
    exit 1
fi

COUNTRY=$(curl -x socks5h://${HOST}:${PORT} -s http://ipconfig.io/country)

UNHEALTHY_COUNTRIES="Iran iran Cuba Russia Syria Venezuela"

if [ -z "$COUNTRY" ]; then
    echo "Failed to get country"
    exit 1
fi

# Loop through the list of unhealthy countries
for country in $UNHEALTHY_COUNTRIES; do
    if [ "$COUNTRY" = "$country" ]; then
        echo "Unhealthy country detected: $COUNTRY"
        exit 1
    fi
done

exit 0