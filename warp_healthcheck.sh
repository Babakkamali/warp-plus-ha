#!/bin/sh

# Check if the SOCKS5 proxy is working
HTTP_CODE=$(curl -x socks5h://127.0.0.1:8086 -o /dev/null -s -w "%{http_code}" http://gstatic.com/generate_204)

if [ "$HTTP_CODE" -ne 204 ]; then
    exit 1
fi

# Check the response from http://ipconfig.io/country
COUNTRY=$(curl -x socks5h://127.0.0.1:8086 -s http://ipconfig.io/country)

UNHEALTHY_COUNTRIES="Iran iran Cuba Russia Syria Venezuela"

if [ -z "$COUNTRY" ]; then
    exit 1
fi

# Loop through the list of unhealthy countries
for country in $UNHEALTHY_COUNTRIES; do
    if [ "$COUNTRY" = "$country" ]; then
        exit 1
    fi
done

exit 0