# Number of GOOL and PSIPHON instances (defaults to 3 if not set)
NUM_GOOL ?= 3
NUM_PSIPHON ?= 3


# Phony targets
.PHONY: all generate up down clean ensure-exec

# Default target
all: generate

ensure-exec:
	@if [ ! -x generate_configs.sh ]; then \
		chmod +x generate_configs.sh; \
		echo "Set executable permission on generate_configs.sh"; \
	fi

# Generate configuration files
generate: ensure-exec
	./generate_configs.sh $(NUM_GOOL) $(NUM_PSIPHON)

# Start Docker Compose services, removing orphan containers if necessary
up: 
	docker compose up -d --remove-orphans


# Stop Docker Compose services
down:
	@if [ -f docker-compose.yml ]; then \
		docker compose down; \
	else \
		echo "No docker-compose.yml found. Services are already stopped."; \
	fi


# Clean up generated files
clean: down
	@if [ -f docker-compose.yml ] || [ -f haproxy.cfg ]; then \
		rm -f docker-compose.yml haproxy.cfg; \
		echo "Removed generated configuration files."; \
	else \
		echo "No generated configuration files to remove. Already clean."; \
	fi
