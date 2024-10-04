# Number of GOOL and PSIPHON instances (defaults to 3 if not set)
NUM_GOOL ?= 3
NUM_PSIPHON ?= 3


# Phony targets
.PHONY: all generate up down clean

# Default target
all: generate

generate:
	chmod 754 generate_configs.sh
	./generate_configs.sh $(NUM_GOOL) $(NUM_PSIPHON)

# Generate configuration files
generate: docker-compose.yml haproxy.cfg

docker-compose.yml haproxy.cfg: generate_configs.sh
	@if [ ! -x generate_configs.sh ]; then \
		chmod 754 generate_configs.sh; \
		echo "Set executable permission on generate_configs.sh"; \
	fi
	./generate_configs.sh $(NUM_GOOL) $(NUM_PSIPHON)

# up will take down all containers incase you have lowered the number of instances
up: down generate
	docker compose up -d

down:
	docker compose down

# takes the containers down and removes all the generated config files
clean: down	
	rm -f docker-compose.yml haproxy.cfg
