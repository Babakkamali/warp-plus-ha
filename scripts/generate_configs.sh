#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Source environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found. Please create one from .env.example by using make init"
    exit 1
fi

# Use the sourced environment variables
NUM_GOOL=${NUM_GOOL}
NUM_PSIPHON=${NUM_PSIPHON}

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

# Function to generate a file and provide feedback
generate_file() {
  local template_file=$1
  local output_file=$2
  local tmp_file1=$3
  local tmp_file2=$4

  # Check if the output file exists to determine status
  if [ -f "$output_file" ]; then
    status="replaced"
  else
    status="created"
  fi

  # Replace placeholders in the template and generate the output file
  sed "/{{$tmp_file1}}/{
      r $5
      d
  }" "$template_file" | \
  sed "/{{$tmp_file2}}/{
      r $6
      d
  }" > "$output_file"

  # Provide feedback to the user
  echo "$output_file has been $status."
}

# Generate docker-compose.yml
if [ -f docker-compose.yml ]; then
    status_docker="replaced"
else
    status_docker="created"
fi

sed '/{{GOOL_SERVICES}}/{
    r gool_services.tmp
    d
}' docker/docker-compose.yml.template | \
sed '/{{PSIPHON_SERVICES}}/{
    r psiphon_services.tmp
    d
}' | \
sed '/{{HAPROXY_DEPENDENCIES}}/{
    r haproxy_dependencies.tmp
    d
}' > docker-compose.yml

echo "docker-compose.yml has been ${status_docker}."

# Generate haproxy.cfg
if [ -f haproxy/haproxy.cfg ]; then
    status_haproxy="replaced"
else
    status_haproxy="created"
fi

sed '/{{GOOL_SERVERS}}/{
    r gool_servers.tmp
    d
}' haproxy/haproxy.cfg.template | \
sed '/{{PSIPHON_SERVERS}}/{
    r psiphon_servers.tmp
    d
}' > haproxy/haproxy.cfg

echo "haproxy/haproxy.cfg has been ${status_haproxy}."

# Clean up temporary files
rm -f gool_services.tmp psiphon_services.tmp haproxy_dependencies.tmp gool_servers.tmp psiphon_servers.tmp

# Final success message
echo "Configuration files generated successfully."
