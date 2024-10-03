NUM_GOOL ?= 3
NUM_PSIPHON ?= 3

all: generate

generate:
	chmod +x generate_configs.sh
	./generate_configs.sh $(NUM_GOOL) $(NUM_PSIPHON)

up: generate
	docker compose up -d

down:
	docker compose down

clean:
	docker compose down -v
	rm -f docker-compose.yml haproxy.cfg
