# Day-27: Managing Containers with Docker Compose

In this section, you will learn how a multi-container application can be managed using Docker Compose. It covers following concepts:

- Declarative vs Imperative orchestration of containers

- Running a multi-service application
- Building images with Docker Compose
  - docker-compose.yaml file
- Deployin an application with Docker Compose
- Scaling a service using Compose
- Building and pushing an application

## Step-27.1: Understanding Declarative vs Imperative Orchestration of Containers

## Step-27.2: Running a multi-service Application using Docker Compose

### Install `Docker Compose`

- You may refer to the official Docker Compose Install documentation here: https://docs.docker.com/compose/install

```bash
# To download and install the Docker Compose CLI plugin
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v5.0.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose

# Apply executable permissions to the downloaded Docker compose binary
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# To verify the Docker Compose Installation
docker compose version
```

- (optional) For a better editing experience for Compose files in VS Code, you may install [Docker DX](https://marketplace.visualstudio.com/items?itemName=docker.docker) extension for linting, code navigation, and vulnerability scanning.

### Demystifying Compose File (docker-compose.yaml)

- The Compose Specification is the latest and recommended version of the Compose file format.
- It helps you define a Compose file which is used to configure your Docker application’s services, networks, volumes, and more.

- Legacy versions 2.x and 3.x of the Compose file format were merged into the Compose Specification.

#### `name` property

- The top-level name property defines the project name.

```bash
name: binapp

services:
  sampleservice:
    image: busybox
    command: echo "I'm running ${COMPOSE_PROJECT_NAME}"
```

#### `services` property

- A Compose file must declare a `services` top-level element as a map whose:
  - _keys_ are string representations of service names
  - _values_ are service definitions

- Each service may also include a `build` section, which explains how to build the Docker image for the service.

```bash
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"

  db:
    image: postgres:18
    environment:
      POSTGRES_USER: example
      POSTGRES_DB: exampledb
```

- For all the supporting `Service` Attributes, you may refer https://docs.docker.com/reference/compose-file/services/#attributes

#### `networks` property

#### `volumes` property

#### `configs` property

#### `secrets` property

## Compose `Build Specification`

## Compose `Deploy Specification`

### Deploy a multi-service application using Docker Compose

## Step-27.3: `Building Images` with Docker Compose

## Step-27.4: `Deploying` an Application using Docker Compose

## Step-27.5: `Scaling` an Application Service using Compose

## Step-27.6: Sample Docker Compose Applications

- Sample Docker Compose Apps - https://github.com/docker/awesome-compose

- Voting Application - https://github.com/dockersamples/example-voting-app
