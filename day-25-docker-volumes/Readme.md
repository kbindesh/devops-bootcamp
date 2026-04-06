# Day-25: Docker Volumes and Configuration

In this section, you will learn the following concepts:

- Understand the use-cases in which containers consume and produce data

- Creating and mounting data volumes
- Sharing data between containers
- Using host volumes
- Defining volumes in images
- Configuring containers

## Step-25.1: Managing `Docker Volumes`

### Step-25.1.1: Getting help around docker volume

```
docker volume --help

# The preceding command will list all the volume related commands
```

### Step-25.1.2: Creating a Docker Volume

- When you create a Docker volume, it is mapped with the `/var/lib/docker/volumes/sample/_data` directory of the host machine.

```bash

# Create a Docker volume
docker volume create $VOLUME_NAME

docker volume create datavol
```

- The default volume driver is the so-called _local driver_, which stores the data locally in the host file system.

```bash
# To get more details about the Volume
docker volume inspect $VOLUME_NAME

docker volume inspect datavol
```

### Step-25.1.3: Mounting a Docker Volume on a Container

- Once you've created a named Docker Volume, you can mount it onto a container:

```bash

# Create a Container with a volume mount
docker container run --name c-with-volume -dit -v datavol:/data alpine /bin/sh

# Inspect the created container for volume mount details
docker container inspect c-with-volume

# Get inside the Container and verify the mountpoint

docker container exec -it c-with-volume /bin/sh

df -h

# Now, add some data to the mountpoint directory i.e. /data
cd /data

echo "This is a sample file" > sampledata.txt

# Exit from the container
exit
OR
Press Ctrl + D

# Next, delete the container to test if the data retains
docker container rm c-with-volume
```

- Next, we will create another Container and mount the same volume to verify if the volume data persists:

```bash

# Create a new container for restoring the data stored on volume
docker container run --name restored-data-c -it --rm -v datavol:/app/restoreddata centos:7 /bin/bash

cd /app/restoreddata

# The preceding command should list one file "sampledata.txt"

# Exit from the container
exit
OR
Press Ctrl + D
```

### Step-25.1.4: Using Host Volumes | Mount a volume on Container using Bind mount

- A bind mount in Docker is a method of mapping a specific file or directory from your host machine's filesystem directly into a container

- Key features
  - Direct Mapping
  - Real-time Syncing

- When to use volume bind mount?
  - When you are doing local development
  - Configuration management
  - Accessing host tools

```bash
# Using the --mount flag (recommended)
docker run -d \
  --name my-app \
  --mount type=bind,source=/path/on/host,target=/app \
  nginx:latest

# Using the -v or --volume flag
docker run -d -v /path/on/host:/app nginx:latest
```

- `Note`
  - While using -v or --volume, if the host path doesn't exist, Docker will automatically create it as a directory

### Step-25.1.5: Sharing data between Containers using Volume

- There can be instances when we might want to share data between containers.
- Say an application running in **Container-A** produces some data that will be consumed by another application running in **Container-B**. How can we achieve this?
  - We can use Docker volumes for this purpose.
  - We can create a volume and mount it to **Container-A**, as well as to **Container-B**.
  - In this way, both container A and B will have access to the same data.

```bash
# Create a Volume i.e. shared-data
docker volume create shared-data

#  Create a Container "writer" and mount the "shared-data" volume on it
docker container run -it --name writer -v shared-data:/data alpine /bin/sh

# Create a file inside the container | it should succeed
echo "I can create a file" > /data/sample.txt

# Exit from the above container by pressing Ctrl+D or "exit"

#  Create another container "reader" and mount the same "shared-data" volume on it in RO mode
docker container run -it --name reader -v shared-data:/app/data:ro ubuntu:22.04 /bin/bash

# You will land inside "reader" container | verify the file created in writer container
ls -l /app/data
```

### Step-25.1.6: Removing a Docker Volume

- Volumes can be removed using the docker volume rm command:

```bash
# Delete an existing volume
docker volume rm $VOLUME_NAME

# Delete all the existing volume
docker volume rm $(docker volume ls -aq)

# Remove all running containers along with any anonymous volume associated with those containers
docker container rm -v -f $(docker container ls -aq)
```
