# Day-23: Managing Docker Containers

In this section, you will learn the following:

- Running your first container

- Starting, stopping, and deleting containers
- Inspecting containers
- Exec into a running container
- Attaching to a running container
- Retrieving container logs

## Step-23.1: Technical Requirements

- Docker Host (with running docker daemon and docker client)

## Step-23.2: Running first Docker Container

```bash
# Check the docker version
docker version

# Create a hello-world container
docker container run hello-world

[You should see a hello from Docker message on the terminal]

# Other examples
docker container run alpine echo "Hello World"
docker container run centos ping -c 5 127.0.0.1
```

## Step-23.3: Listing Containers

```bash
# List only "Running" Containers (default)
docker container ls
OR
docker ps

# List all the Containers (including the stopped ones)
docker container ls -a
OR
docker container ls --all
or
docker ps -a

# List just the IDs of all containers
docker container ls --quiet
```

## Step-23.4: Starting, Stopping Containers

In the previous step, you successfully ran a container. Let's create another Container:

```
# Create a new container using Apache HTTPD Server image
docker container run -dit --name webapp -p 4000:80 httpd:latest

# List Containers
docker container ls
OR
docker ps

[You should see deployed container "webapp" in the list]

# Now, let's stop the running container "webapp"
docker container stop $CONTAINER_NAME_OR_ID
docker container stop webapp
```

#### `Important`

- When you stop a Container, docker sends a Linux `SIGTERM` signal to the main process running inside the container.

- If the process doesn't respond to this signal and terminate itself, Docker waits for 10 seconds and then sends `SIGKILL`, which will kill the process forcefully and terminate the container.

```
# To start the stopped Container again
docker container start $CONTAINER_NAME_OR_ID
docker container start webapp
```

## Step-23.5: Inspecting Containers

- To get more information about a specific container, we can use the `docker container inspect` command.

```
# Inspect a Container named "webapp"
docker container inspect webapp
```

## Step-23.6: Execute (exec) command into a running Container

- Sometimes, we might want to run another process/command inside an already-running container.
- A typical reason could be - You trying to debug a container which is running an application.

```
# Execute a process inside a running container
docker container exec -it $CONTAINER_NAME $COMMAND

docker container exec -it webapp /bin/bash
```

- **-i (or --interactive)** flag signifies that we want to run the additional process interactively.

- **-t (or --tty)** tells Docker that we want it to provide us with a TTY (a terminal emulator) for
  the command.
- **/bin/sh** is the process that we would like to run inside the container.

```
# Execute a process bourne shell inside a running container "webapp"
docker container exec -it webapp /bin/bash

[We're now in a Bourne shell inside the webapp Container]

# Run few random commands to get more details about the Container
pwd
hostname

# To exit from Container shell and go back to host terminal
Press "Ctrl + D"
OR
Type "exit"
```

## Step-23.7: Retrieving Container logs

- It is always good to get some logging information about application to figure out what the application is doing at a given time.
- To check whether there are any problems associated with the App;
- Root cause of the issue.

- To access the logs of a given container, you can run `docker container logs` command.

```
docker container logs $CONTAINER_NAME_OR_ID

docker container logs webapp

# To get container logs only a few of the latest entries
docker container logs --tail 5 $CONTAINER_NAME_OR_ID

# To follow the log that is produced by a container
docker container logs --tail 5 --follow webapp
OR
docker container logs --tail 5 -f webapp

[Press "Ctrl + C" to stop following the logs]
```

## Step-23.8: Removing/Deleting Containers

```
docker container rm $CONTAINER_NAME_OR_ID
docker container rm webapp

# Sometimes, we need to forcefully remove a Container
docker container rm $CONTAINER_NAME_OR_ID --force
```
