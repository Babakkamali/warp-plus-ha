#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

HOST="$3" # third parameter should be host IP
PORT="$4" # fourth parameter should be host port

MAX_LATENCY=2 # Maximum allowed latency in seconds
# Print all environment variables for debugging

# Check if the SOCKS5 proxy is working and measure latency
RESULT=$(curl -x socks5h://${HOST}:${PORT} -o /dev/null -s -w "%{http_code} %{time_total}" http://gstatic.com/generate_204)
HTTP_CODE=$(echo $RESULT | awk '{print $1}')
LATENCY=$(echo $RESULT | awk '{print $2}')

# Check if the HTTP code is 204 (indicating success)
if [ "$HTTP_CODE" != "204" ]; then
    exit 1
fi

# Check if the latency exceeds the allowed maximum
if (( $(echo "$LATENCY > $MAX_LATENCY" | bc -l) )); then
    echo "Latency too high: $LATENCY seconds (Server: ${HAPROXY_SERVER_NAME:-unknown})"
    exit 1
fi

# Check the country of the proxy
COUNTRY=$(curl -x socks5h://${HOST}:${PORT} -s http://ipconfig.io/country)

UNHEALTHY_COUNTRIES="Iran iran Cuba Russia Syria Venezuela"

if [ -z "$COUNTRY" ]; then
    echo "Failed to get country (Server: ${HAPROXY_SERVER_NAME:-unknown})"
    exit 1
fi

# Loop through the list of unhealthy countries
for country in $UNHEALTHY_COUNTRIES; do
    if [ "$COUNTRY" = "$country" ]; then
        echo "Unhealthy country detected: $COUNTRY (Server: ${HAPROXY_SERVER_NAME:-unknown})"
        exit 1
    fi
done

exit 0
