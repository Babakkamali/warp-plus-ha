#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

ENV_FILE=".env"
# Source environment variables from .env file
if [ -f "$ENV_FILE" ]; then
    # Export all variables from .env, handling quotes and spaces correctly
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "Error: .env file not found. Please create one from .env.example by using make init"
    exit 1
fi

# Use the sourced environment variables
NUM_GOOL=${NUM_GOOL}
NUM_PSIPHON=${NUM_PSIPHON}
XRAY_SERVICES=""
GOOL_SERVICES=""
PSIPHON_SERVICES=""
HAPROXY_DEPENDENCIES=""
GOOL_SERVERS=""
PSIPHON_SERVERS=""
HAPROXY_PORTS=""

# Validate NUM_GOOL and NUM_PSIPHON
if ! [[ "$NUM_GOOL" =~ ^[0-9]+$ ]]; then
    echo "Error: NUM_GOOL must be a positive integer."
    exit 1
fi

if ! [[ "$NUM_PSIPHON" =~ ^[0-9]+$ ]]; then
    echo "Error: NUM_PSIPHON must be a positive integer."
    exit 1
fi

# Conditional check for SOCKS_PUBLISH
if [ "$HAPROXY_SOCKS_PUBLISH" = "true" ]; then
  HAPROXY_PORTS='    ports:
          - "${HAPROXY_GOOL_PORT}:1080"
          - "${HAPROXY_PSIPHON_PORT}:1081"'
else
  echo "SOCKS publishing disabled. Skipping port publishing."
fi

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

# Xray Docker Compose service generation
# Check if any of the XRAY_*_ENABLED variables are set to true
if [ "$XRAY_ENABLED" = "true" ] || [ "$XRAY_LOCAL_ENABLED" = "true" ]; then
    echo "Xray Docker services are enabled. Generating docker-compose services..."

    # Generate the xray-gool and xray-psiphon services if XRAY_ENABLED is true
    if [ "$XRAY_ENABLED" = "true" ]; then
        XRAY_SERVICES+="  xray-gool:\n"
        XRAY_SERVICES+="    <<: *xray-core\n"
        XRAY_SERVICES+="    ports:\n"
        XRAY_SERVICES+="      - \"${XRAY_GOOL_PORT}:${XRAY_GOOL_PORT}\"\n"
        XRAY_SERVICES+="    volumes:\n"
        XRAY_SERVICES+="      - ./xray/gool_config.json:/etc/xray/config.json\n"
        XRAY_SERVICES+="\n"

        XRAY_SERVICES+="  xray-psiphon:\n"
        XRAY_SERVICES+="    <<: *xray-core\n"
        XRAY_SERVICES+="    ports:\n"
        XRAY_SERVICES+="      - \"${XRAY_PSIPHON_PORT}:${XRAY_PSIPHON_PORT}\"\n"
        XRAY_SERVICES+="    volumes:\n"
        XRAY_SERVICES+="      - ./xray/psiphon_config.json:/etc/xray/config.json\n"
        XRAY_SERVICES+="\n"
    else
        echo "XRAY_ENABLED is false. Skipping xray-gool and xray-psiphon services."
    fi

    # Generate the xray-local service if XRAY_LOCAL_ENABLED is true
    if [ "$XRAY_LOCAL_ENABLED" = "true" ]; then
        echo "xray-local service is enabled. Generating docker-compose service..."

        XRAY_SERVICES+="  xray-local:\n"
        XRAY_SERVICES+="    <<: *xray-core\n"
        XRAY_SERVICES+="    ports:\n"
        XRAY_SERVICES+="      - \"${XRAY_LOCAL_PORT}:${XRAY_LOCAL_PORT}\"\n"
        XRAY_SERVICES+="    volumes:\n"
        XRAY_SERVICES+="      - ./xray/local_config.json:/etc/xray/config.json\n"
        XRAY_SERVICES+="\n"
    else
        echo "XRAY_LOCAL_ENABLED is false. Skipping xray-local service."
    fi

else
    # Don't add Xray services to dependencies if XRAY_ENABLED and XRAY_LOCAL_ENABLED are false
    echo "Xray services are disabled. Skipping Docker Compose service generation."
fi

# Write the generated content to temporary files
echo -e "$GOOL_SERVICES" > gool_services.tmp
echo -e "$PSIPHON_SERVICES" > psiphon_services.tmp
echo -e "$HAPROXY_DEPENDENCIES" > haproxy_dependencies.tmp
echo -e "$GOOL_SERVERS" > gool_servers.tmp
echo -e "$PSIPHON_SERVERS" > psiphon_servers.tmp
echo -e "$XRAY_SERVICES" > xray_services.tmp

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
sed '/{{XRAY_SERVICES}}/{
    r xray_services.tmp
    d
}' | \
sed '/{{HAPROXY_DEPENDENCIES}}/{
    r haproxy_dependencies.tmp
    d
}' > docker-compose.yml.intermediate

# Conditionally replace or remove the HAPROXY_PORTS placeholder
if [ "$HAPROXY_SOCKS_PUBLISH" = "true" ]; then
    # Write HAPROXY_PORTS content to a temporary file
    echo "$HAPROXY_PORTS" > haproxy_ports.tmp
    
    # Use sed to insert the contents of haproxy_ports.tmp and delete the placeholder line
    sed '/### HAPROXY_PORTS ###/{
        r haproxy_ports.tmp
        d
    }' docker-compose.yml.intermediate > docker-compose.yml
else
    # Remove the placeholder if ports are not applied
    sed '/### HAPROXY_PORTS ###/d' docker-compose.yml.intermediate > docker-compose.yml
fi

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
rm -f gool_services.tmp psiphon_services.tmp haproxy_dependencies.tmp gool_servers.tmp psiphon_servers.tmp xray_services.tmp haproxy_ports.tmp docker-compose.yml.intermediate

### xray config generation
# Check if any xray configuration is enabled
if [ "$XRAY_ENABLED" = "true" ] || [ "$XRAY_LOCAL_ENABLED" = "true" ]; then
    echo "Xray configuration is enabled. Generating config files..."

    # Paths to the template and output config files
    TEMPLATE_FILE="./xray/config.template.json"
    GOOL_OUTPUT_FILE="./xray/gool_config.json"
    PSIPHON_OUTPUT_FILE="./xray/psiphon_config.json"

    # Function to generate config files and provide feedback
    generate_xray_config() {
        local template_file=$1
        local output_file=$2
        local port_var=$3
        local uuid_var=$4
        local email_var=$5
        local outbound_port_var=$6  # May be empty

        # Check if the output file exists
        if [ -f "$output_file" ]; then
            status="replaced"
        else
            status="created"
        fi

        # Build sed expression
        sed_expr="s/\${XRAY_PORT}/${!port_var}/g; s/\${XRAY_UUID}/${!uuid_var}/g; s/\${XRAY_EMAIL}/${!email_var}/g"

        # If outbound_port_var is not empty, add replacement
        if [ -n "$outbound_port_var" ]; then
            sed_expr+="; s/\${XRAY_OUTBOUND_PORT}/${!outbound_port_var}/g"
        fi

        # Replace placeholders in the template and generate the output file
        sed -e "$sed_expr" "$template_file" > "$output_file"

        # Provide feedback to the user
        echo "$output_file has been $status."
    }

    # Generate config files for GOOL if XRAY_ENABLED=true
    if [ "$XRAY_ENABLED" = "true" ]; then
        generate_xray_config "$TEMPLATE_FILE" "$GOOL_OUTPUT_FILE" "XRAY_GOOL_PORT" "XRAY_GOOL_UUID" "XRAY_GOOL_EMAIL" "HAPROXY_GOOL_PORT"

        # Generate config files for PSIPHON
        generate_xray_config "$TEMPLATE_FILE" "$PSIPHON_OUTPUT_FILE" "XRAY_PSIPHON_PORT" "XRAY_PSIPHON_UUID" "XRAY_PSIPHON_EMAIL" "HAPROXY_PSIPHON_PORT"
    fi

    # Generate config files for xray-local if XRAY_LOCAL_ENABLED=true
    if [ "$XRAY_LOCAL_ENABLED" = "true" ]; then
        LOCAL_TEMPLATE_FILE="./xray/config-local.template.json"
        LOCAL_OUTPUT_FILE="./xray/local_config.json"
        generate_xray_config "$LOCAL_TEMPLATE_FILE" "$LOCAL_OUTPUT_FILE" "XRAY_LOCAL_PORT" "XRAY_LOCAL_UUID" "XRAY_LOCAL_EMAIL" ""
    fi

else
    echo "Xray configuration is disabled. Skipping config generation."
fi

# Final success message
echo "Configuration files generated successfully."
