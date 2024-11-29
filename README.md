# Warp Plus HA Proxy with Auto-Healing

TThis project offers a simple and automated solution for bypassing geo-location restrictions using [Warp Plus](https://github.com/bepass-org/warp-plus) in combination with **gool** (Warp-in-Warp) and **Psiphon** services. It leverages Docker and HAProxy to create a load-balanced environment that automatically manages service instances, handles sudden disconnects, and ensures optimal proxy performance.

## Features

- **Automatic Service Generation**: Dynamically creates multiple service instances for gool and Psiphon based on configuration.
- **Load Balancing with HAProxy**: Distributes traffic across healthy service instances to optimize performance.
- **Auto-Healing Mechanism**: Automatically checks the health of each container and restarts unhealthy services.
- **Latency Monitoring**: Checks the latency of each tunnel and removes instances with high response times.
- **Geo-Restriction Handling**: Identifies and excludes services using undesired IP addresses (e.g., specific countries).
- **Dockerized Environment**: Utilizes Docker and Docker Compose for easy deployment and management.
- **Scripted Configuration Generation**: Uses env file and templates and scripts to generate configuration files dynamically.
- **Remote Access Using Xray**: You can access the service securly using xray clients

## Prerequisites

Prerequisites installation method for debian based linux distributions:

```
sudo apt update && apt install -y \
    docker.io \
    docker-compose-v2 \
    uuid-runtime \
    git \
    make
    
```

## Installation

1. **Clone the Repository**

   ```
   git clone https://github.com/Babakkamali/warp-plus-ha.git
   cd warp-plus-ha
   ```

2. **Install Dependencies**

   Make sure Docker and Docker Compose are installed and running on your system.

## Usage

The project uses a Makefile to simplify common tasks such as generating configuration files, starting up the services, and cleaning up. Below are the available commands and how to use them.

### Create .env File

To create .env file from .env.example you can simply run:

```
make init
```

you can read all the variables and change them to your needs

To specify the number of gool and Psiphon services, edit .env file:

```
# Number of GOOL instances
NUM_GOOL=5

# Number of PSIPHON instances
NUM_PSIPHON=2
```
and rerun generate command from make file

### Generate Configuration Files

This command will generate the necessary files for running the project

```
make generate
```

The generated files are `docker-compose.yml` and `haproxy/haproxy.cfg`, based on the .env content.

### Start the Services

Generate the configuration files and start all services:

```
make up
```

### Stop the Services

To stop all running services:

```
make down
```

### Clean Up

To stop all services and remove generated configuration files:

```
make clean
```

### Satch Service Status

To watch all services health and status simply run:

```
make ps
```

## Configuration

The project uses template files to generate the necessary configuration files dynamically.

- **Templates:**
  - `docker/docker-compose.yml.template`
  - `haproxy/haproxy.cfg.template`

- **Scripts:**
  - `scripts/generate_configs.sh`: Generates the configuration files based on the templates and the specified number of services.

### Customizing the Number of Services

You can customize the number of gool and Psiphon services by setting the env variables in the .env file and then rerun the `make` commands.

Example:

```
make init
vim .env
make generate
make up
```

## License

This project is licensed under the [MIT License](LICENSE).

---

**Disclaimer**: This project is for educational and testing purposes. Use responsibly and ensure compliance with all applicable laws and terms of service.
