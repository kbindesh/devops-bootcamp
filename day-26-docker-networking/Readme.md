# Day-26: Docker Container Networking

In this section, you will learn the following concepts:

- Understanding the container network model
- Docker Network Drivers
- Working with the bridge network
- The host and null network
- Managing container ports

## Step-26.1: Overview

- Container networking refers to the ability for containers to connect and communicate with other containers, resources and with external non-Docker resources.

- By default, containers have networking enabled. Hence, they can make outbound connections.

- There are various Docker Network types (drivers), some of them are as follows:

| Network | Company | Scope  | Description                                                                                                        |
| ------- | ------- | ------ | ------------------------------------------------------------------------------------------------------------------ |
| bridge  | Docker  | local  | Simple network based on Linux bridges to allow<br>networking on a single host                                      |
| host    | Docker  | local  | Allows a container to share the host machine's network stack directly, removing the network isolation between them |
| none    | Docker  | local  | A built-in network driver used to completely isolate a container's networking stack                                |
| overlay | Docker  | Global | Multi-node capable container network based on<br>Virtual Extensible LAN                                            |
| mcvlan  | Docker  | local  | Configures multiple layer-2 (that is, MAC)<br>addresses on a single physical host interface                        |

## Step-26.2: Working with the `bridge` network

- When the Docker daemon runs for the first time, it creates a Linux bridge interface called `docker0`.

- By default, all the containers that you deploy without explicitly specifying the network goes to the _default_ bridge network.

```bash
# To verify the "default" bridge network, list all the networks
docker network ls

# To get more details about default bridge network
docker network inspect bridge

# Observe ID, Name, Driver and Scope values from the output of preceding command
```

### Step-26.2.1: Create a custom `bridge` network and deploy a Container to it

```bash
# Create a custom network with our own subnet range
docker network create --driver bridge --subnet "10.10.0.0/20" dev-net

# Inspect above network
docker network inspect dev-net

# Deploy a Container in our custom network i.e. dev-net
docker container run --name bridge-nw-c1 -dit --network dev-net alpine:latest /bin/sh

# Inspect the above created container and observe the "NetworkSettings" section
docker container inspect bridge-nw-c1

# Now, deploy another container in the same bridge network
docker container run --name bridge-nw-c2 -dit --network dev-net alpine:latest /bin/sh

# To check if containers "bridge-nw-c1" and "bridge-nw-c2" are able to communicate
docker container exec -it bridge-nw-c1 ping bridge-nw-c2

# Alternatively, you can remove all the networks that no container is attached
docker network prune --force
```

## Step-26.3: Working with the `host` network

- There are instances when we would want to run a container in the _network namespace_ of the _host_.

- `host` network is a predefined docker network.

- `Important`
  - You cannot create a custom network using the `host` driver in Docker.
  - The `host` network is a single, predefined singleton network that maps a container directly to the host's networking stack.

### 26.3.1 Deploy a container in a host network

```bash
docker container run --rm -it --network host alpine:latest /bin/sh

# To analyze the network namespace from within the container
ip addr

# The preceding command will list the same set of network interfaces as host
```

- Running containers on host networks can be potentially risky due to potential security vulnerabilities and conflicts:
  1. Security risks
  2. Port conflicts with the host
  3. Loosing the container level isolation

## Step-26.4: Working with the `null` network

- There are instances when we would want to run a few application services or jobs that do not need any network connection at all to execute the task.

- You may run such applications in a container that is attached to the `none` network.
- This container will be completely isolated from outside access.

```bash
# Create a container in "none" network
docker container run --rm -it --network none alpine:latest /bin/sh

# Once inside the container, you can verify that there is no eth0 network endpoint
ip addr

# The preceding command output won't show any network interface except for loopback

ip route

# The preceding command output won't return anything
```

## Step-26.5: Managing container ports

- In order to expose an application service running inside out container to the outside world, we've to open a gate wide enough in our firewall through which we can funnel external traffic to our Application.

- Let's see how we can actually map a container port to a host port.

### Step-26.5.1: Docker Automatic Port mapping (-P)

- With `-P` option of `docker container run` command, we can let Docker decide which host port our container port should be mapped to.

- Docker will then select one of the free host ports in the range of 32xxx.

```BASH
# Docker automatic port mapping using -P flag
docker container run --name sample-app -P -d nginx:alpine

# The preceding command runs an nginx container on port 80

# To check the container port specifications (both container & host)
docker container port $CONTAINER_NAME
docker container port sample-app
```

### Step-26.5.2: Manual Port Mapping (-p)

- With `-p` option of `docker container run` command, we can manually specify on which host port to map our container port.

- Syntax : `-p $HOST_PORT:$CONTAINER_PORT`

```
# Docker manual port mapping using -p flag
docker container run --name web-app -dit -p 4000:80 httpd

# To check the container port specifications (both container & host)
docker container port $CONTAINER_NAME

docker container port web-app

OR

docker container inspect web-app

OR

docker container ls -a
```

## Step-26.6: Assignments

- Create 2 networks of type _bridge_ namely nw-1 and nw-2. Then deploy 1 container each in nw-1 and nw-2 respectively. Check if they can communicate.

- Create 2 networks of type _bridge_ namely nw-1, nw-2. Deploy c1 in nw-1 and c2 in both nw-1 and nw-2. Kindly check if c1 is reachable from nw2.
