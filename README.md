# Warp Plus Auto-Managed Load-Balanced Proxy with Auto-Healing

This project provides an easy, automated, scalable, and resilient proxy solution using [Warp Plus](https://github.com/bepass-org/warp-plus) in combination with **gool** (Warp-in-Warp) and **Psiphon** services. It leverages Docker and HAProxy to create a load-balanced environment that automatically manages service instances, handles sudden disconnects, and ensures optimal proxy performance.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
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

   Ensure that the `generate_configs.sh` script is executable:

   ```
   chmod +x generate_configs.sh
   ```

## Usage

The project uses a Makefile to simplify common tasks such as generating configuration files, starting up the services, and cleaning up. Below are the available commands and how to use them.

### Generate Configuration Files

To generate the `docker-compose.yml` and `haproxy.cfg` files with default settings:

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

This command is equivalent to:

```
make generate
docker-compose up
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
  - `docker-compose.yml.template`
  - `haproxy.cfg.template`

- **Scripts:**
  - `generate_configs.sh`: Generates the configuration files based on the templates and the specified number of services.

### Customizing the Number of Services

You can customize the number of gool and Psiphon services by setting the `NUM_GOOL` and `NUM_PSIPHON` variables when running the `make` commands.

Example:

```
make up NUM_GOOL=5 NUM_PSIPHON=3
```

## Project Structure

- **Dockerfile**: Builds the Warp Plus service image.
- **Dockerfile.haproxy**: Builds the HAProxy image.
- **generate_configs.sh**: Bash script to generate configuration files from templates.
- **docker-compose.yml.template**: Template for the Docker Compose configuration.
- **haproxy.cfg.template**: Template for the HAProxy configuration.
- **Makefile**: Automates tasks like generating configs, starting/stopping services, and cleaning up.
- **healthcheck.sh**: Script used by HAProxy for health checks.
- **.gitignore**: Specifies files to be ignored by Git (e.g., generated configs).
- **README.md**: Documentation and usage instructions.

## Best Practices

- **Version Control**: Generated files like `docker-compose.yml` and `haproxy.cfg` are added to `.gitignore` to prevent them from being tracked in Git.
- **Scripted Automation**: Use the `Makefile` and `generate_configs.sh` script to automate repetitive tasks and ensure consistency.
- **Health Checks**: Regular health checks and auto-healing ensure high availability and reliability.
- **Resource Management**: Monitor the number of service instances to optimize resource usage and performance.


## License

This project is licensed under the [MIT License](LICENSE).

---

**Disclaimer**: This project is for educational and testing purposes. Use responsibly and ensure compliance with all applicable laws and terms of service.
