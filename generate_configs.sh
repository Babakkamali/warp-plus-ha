#!/bin/bash

# Default number of services if not provided
NUM_GOOL=${1:-3}
NUM_PSIPHON=${2:-3}

# Initialize variables
GOOL_SERVICES=""
PSIPHON_SERVICES=""
HAPROXY_DEPENDENCIES=""
GOOL_SERVERS=""
PSIPHON_SERVERS=""

# Generate GOOL services
for i in $(seq 1 $NUM_GOOL); do
  GOOL_SERVICES+="  gool-$i:\n    <<: *warp-plus-gool\n\n"
  HAPROXY_DEPENDENCIES+="      - gool-$i\n"
  GOOL_SERVERS+="    server gool-$i gool-$i:8086 check\n"
done

# Generate PSIPHON services
for i in $(seq 1 $NUM_PSIPHON); do
  PSIPHON_SERVICES+="  psiphon-$i:\n    <<: *warp-plus-psiphon\n\n"
  HAPROXY_DEPENDENCIES+="      - psiphon-$i\n"
  PSIPHON_SERVERS+="    server psiphon-$i psiphon-$i:8086 check\n"
done

# Write the generated content to temporary files
echo -e "$GOOL_SERVICES" > gool_services.tmp
echo -e "$PSIPHON_SERVICES" > psiphon_services.tmp
echo -e "$HAPROXY_DEPENDENCIES" > haproxy_dependencies.tmp
echo -e "$GOOL_SERVERS" > gool_servers.tmp
echo -e "$PSIPHON_SERVERS" > psiphon_servers.tmp

# Replace placeholders in docker-compose.yml.template
sed '/{{GOOL_SERVICES}}/{
    r gool_services.tmp
    d
}' docker-compose.yml.template | \
sed '/{{PSIPHON_SERVICES}}/{
    r psiphon_services.tmp
    d
}' | \
sed '/{{HAPROXY_DEPENDENCIES}}/{
    r haproxy_dependencies.tmp
    d
}' > docker-compose.yml

# Replace placeholders in haproxy.cfg.template
sed '/{{GOOL_SERVERS}}/{
    r gool_servers.tmp
    d
}' haproxy.cfg.template | \
sed '/{{PSIPHON_SERVERS}}/{
    r psiphon_servers.tmp
    d
}' > haproxy.cfg

# Clean up temporary files
rm gool_services.tmp psiphon_services.tmp haproxy_dependencies.tmp gool_servers.tmp psiphon_servers.tmp
