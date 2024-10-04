# Warp Plus Auto-Managed Load-Balanced Proxy with Auto-Healing

This project provides an easy, automated, scalable, and resilient proxy solution using [Warp Plus](https://github.com/bepass-org/warp-plus) in combination with **gool** (Warp-in-Warp) and **Psiphon** services. It leverages Docker and HAProxy to create a load-balanced environment that automatically manages service instances, handles sudden disconnects, and ensures optimal proxy performance.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [License](#license)

## Overview

This project was created to address the need for a robust and self-healing proxy system that can handle high availability and scaling. By integrating Warp Plus with gool and Psiphon services, the system provides a reliable proxy solution capable of managing multiple service instances, load balancing, and automatic health checks.

## Features

- **Automatic Service Generation**: Dynamically creates multiple service instances for gool and Psiphon based on configuration.
- **Load Balancing with HAProxy**: Distributes traffic across healthy service instances to optimize performance.
- **Auto-Healing Mechanism**: Automatically checks the health of each container and restarts unhealthy services.
- **Latency Monitoring**: Checks the latency of each tunnel and removes instances with high response times.
- **Geo-Restriction Handling**: Identifies and excludes services using undesired IP addresses (e.g., specific countries).
- **Dockerized Environment**: Utilizes Docker and Docker Compose for easy deployment and management.
- **Scripted Configuration Generation**: Uses templates and scripts to generate configuration files dynamically.

## Prerequisites

- **Docker**: Ensure that Docker is installed on your system.
- **Docker Compose**: Required for orchestrating multiple Docker containers.
- **GNU Make**: To utilize the Makefile for easy command execution.
- **Git**: For cloning the repository and version control.

Prerequisites installation method for debian based linux distributions:

```
sudo apt install -y \
    docker.io \
    docker-compose-v2 \
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

3. **Set Execution Permissions**

   Ensure that the `scripts/generate_configs.sh` script is executable:

   ```
   chmod +x scripts/generate_configs.sh
   ```

## Usage

The project uses a Makefile to simplify common tasks such as generating configuration files, starting up the services, and cleaning up. Below are the available commands and how to use them.

### Generate Configuration Files

To generate the `docker-compose.yml` and `haproxy/haproxy.cfg` files with default settings:

```
make generate
```

To specify the number of gool and Psiphon services, use:

```
make generate NUM_GOOL=5 NUM_PSIPHON=4
```

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

## Configuration

The project uses template files to generate the necessary configuration files dynamically.

- **Templates:**
  - `docker/docker-compose.yml.template`
  - `haproxy/haproxy.cfg.template`

- **Scripts:**
  - `scripts/generate_configs.sh`: Generates the configuration files based on the templates and the specified number of services.

### Customizing the Number of Services

You can customize the number of gool and Psiphon services by setting the `NUM_GOOL` and `NUM_PSIPHON` variables when running the `make` commands.

Example:

```
make generate NUM_GOOL=2 NUM_PSIPHON=5
make up
```

## License

This project is licensed under the [MIT License](LICENSE).

---

**Disclaimer**: This project is for educational and testing purposes. Use responsibly and ensure compliance with all applicable laws and terms of service.
