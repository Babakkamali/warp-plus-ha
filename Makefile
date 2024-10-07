# Phony targets to prevent conflicts with file names
.PHONY: all generate up ps down clean build build-no-cache ensure-exec require-configs init

# Default target
all: generate

# Ensure generate_configs.sh is executable
ensure-exec:
	@if [ ! -x scripts/generate_configs.sh ]; then \
                chmod +x scripts/generate_configs.sh; \
                echo "Set executable permission on scripts/generate_configs.sh"; \
        fi

# Macro to check the existence of a file with a custom message
define CHECK_FILE
        @if [ ! -f $1 ]; then \
                echo "$2"; \
                exit 1; \
        fi
endef

# Target to require both docker-compose.yml and haproxy/haproxy.cfg
require-configs:
	$(call CHECK_FILE, docker-compose.yml, "Error: 'docker-compose.yml' does not exist. Please run 'make generate' first.")
	$(call CHECK_FILE, haproxy/haproxy.cfg, "Error: 'haproxy/haproxy.cfg' does not exist. Please run 'make generate' first.")

# Initialize the environment by copying .env.example to .env if .env does not exist
init:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "Copied .env.example to .env. Please review and modify as needed."; \
        	XRAY_GOOL_PORT=$$(shuf -i 49152-65535 -n 1); \
	        XRAY_PSIPHON_PORT=$$(shuf -i 49152-65535 -n 1); \
	        XRAY_LOCAL_PORT=$$(shuf -i 49152-65535 -n 1); \
	        XRAY_GOOL_UUID=$$(uuidgen); \
	        XRAY_PSIPHON_UUID=$$(uuidgen); \
	        XRAY_LOCAL_UUID=$$(uuidgen); \
	        sed -i "s/^XRAY_GOOL_PORT=.*/XRAY_GOOL_PORT=$$XRAY_GOOL_PORT/" .env; \
	        sed -i "s/^XRAY_GOOL_UUID=.*/XRAY_GOOL_UUID=$$XRAY_GOOL_UUID/" .env; \
	        sed -i "s/^XRAY_PSIPHON_PORT=.*/XRAY_PSIPHON_PORT=$$XRAY_PSIPHON_PORT/" .env; \
	        sed -i "s/^XRAY_PSIPHON_UUID=.*/XRAY_PSIPHON_UUID=$$XRAY_PSIPHON_UUID/" .env; \
	        sed -i "s/^XRAY_LOCAL_PORT=.*/XRAY_LOCAL_PORT=$$XRAY_LOCAL_PORT/" .env; \
	        sed -i "s/^XRAY_LOCAL_UUID=.*/XRAY_LOCAL_UUID=$$XRAY_LOCAL_UUID/" .env; \
	        echo "Xray configuration (ports and UUIDs) generated and inserted into .env."; \
	else \
		echo ".env already exists. Skipping copy."; \
	fi
        
# Generate configuration files
generate: ensure-exec
	./scripts/generate_configs.sh

# Start Docker Compose services, removing orphan containers if necessary
up: require-configs
	docker compose up -d --remove-orphans
	docker compose restart haproxy
	@if docker compose ps | grep -q "xray-gool"; then \
		echo "Restarting xray-gool..."; \
		docker compose restart xray-gool; \
	fi
	@if docker compose ps | grep -q "xray-psiphon"; then \
		echo "Restarting xray-psiphon..."; \
		docker compose restart xray-psiphon; \
	fi
	@if docker compose ps | grep -q "xray-local"; then \
		echo "Restarting xray-local..."; \
		docker compose restart xray-local; \
	fi

# Monitor Docker Compose services
ps: require-configs
	watch -n 0.5 "docker compose ps"

# Stop Docker Compose services
down: require-configs
	docker compose down

# Clean up generated files
clean: down 
	rm -f docker-compose.yml haproxy/haproxy.cfg xray/gool_config.json xray/psiphon_config.json
	echo "Removed generated configuration files."

# Build Docker images without using cache
build: require-configs
	docker compose build

build-no-cache: require-configs
	docker compose build --no-cache
