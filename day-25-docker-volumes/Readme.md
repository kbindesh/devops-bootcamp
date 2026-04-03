# Day-25: Docker Volumes and Configuration

In this section, you will learn the following concepts:

- Understand the use-cases in which containers consume and produce data

- Creating and mounting data volumes
- Sharing data between containers
- Using host volumes
- Defining volumes in images
- Configuring containers

## Managing `Docker Volumes`

### Getting help around docker volume

```
docker volume --help

# The preceding command will list all the volume related commands
```

### Creating a Docker Volume

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

### Mounting a Docker Volume on a Container

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

### Removing a Docker Volume

- Volumes can be removed using the docker volume rm command:

```bash
# Delete an existing volume
docker volume rm $VOLUME_NAME

# To remove all running containers along with any anonymous volume associated with those containers
docker container rm -v -f $(docker container ls -aq)
```

### Access Docker Volumes
