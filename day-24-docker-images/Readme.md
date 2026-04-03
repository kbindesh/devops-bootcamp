# Day-24: Creating and Managing `Docker Images`

In this section, you will learn the following:

- Docker Images Overview
- What is Dockerfile? | Instructions | Creating Dockerfile
- Creating Docker Images - Packaging an Application into an Image

- Sharing or shipping Docker Images
- Optimize Docker Images

## Step-24.1: Docker Images - Overview

- _Container images_ are read-only templates from which _containers_ are created.

- These Docker Images are made-up of multiple layers.

- The first layer in the image is also called
  the `base layer`.

- Each layer contains adds some content or information to the Docker Image.
- The layers of a container image are all immutable
  - i.e. once generated, the layer
    cannot ever be changed.
  - The only possible operation affecting the layer is its physical deletion.

- A Docker image is made up of a collection of files that bundle together all the essentials required to run enable containerized application to run as expected, such as:
  - Runtime
  - Operating System
  - Application code/Build Artifacts
  - Dependencies
  - Port specifications
  - Environment variables

- When we create a container from an image, it adds a writable container layer on top of
  this stack of immutable layers.

## Step-24.2: Different ways of Creating Docker Images

### Step-24.2.1: Create a Docker Image using `Dockerfile`

- A `Dockerfile` is a text file which contains instructions on how to build a custom container image.
- It is a declarative way of packaging application into Docker Images.

- For more details around Dockerfile, you may refer https://docs.docker.com/reference/dockerfile/

#### Step-24.2.1.1: Dockerfile Instructions

| Instruction                                                                       | Description                                                 |
| --------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| [ADD](https://docs.docker.com/reference/dockerfile/#add)                          | Add local or remote files and directories.                  |
| [ARG](https://docs.docker.com/reference/dockerfile/#arg)                          | Use build-time variables.                                   |
| [CMD](https://docs.docker.com/reference/dockerfile/#cmd)                          | Specify default commands.                                   |
| [COPY](https://docs.docker.com/reference/dockerfile/#copy)                        | Copy files and directories.                                 |
| [ENTRYPOINT](https://docs.docker.com/reference/dockerfile/#entrypoint)            | Specify default executable.                                 |
| [ENV](https://docs.docker.com/reference/dockerfile/#env)                          | Set environment variables.                                  |
| [EXPOSE](https://docs.docker.com/reference/dockerfile/#expose)                    | Describe which ports your application is listening on.      |
| [FROM](https://docs.docker.com/reference/dockerfile/#from)                        | Create a new build stage from a base image.                 |
| [HEALTHCHECK](https://docs.docker.com/reference/dockerfile/#healthcheck)          | Check a container's health on startup.                      |
| [LABEL](https://docs.docker.com/reference/dockerfile/#label)                      | Add metadata to an image.                                   |
| [MAINTAINER](https://docs.docker.com/reference/dockerfile/#maintainer-deprecated) | Specify the author of an image.                             |
| [ONBUILD](https://docs.docker.com/reference/dockerfile/#onbuild)                  | Specify instructions for when the image is used in a build. |
| [RUN](https://docs.docker.com/reference/dockerfile/#run)                          | Execute build commands.                                     |
| [SHELL](https://docs.docker.com/reference/dockerfile/#shell)                      | Set the default shell of an image.                          |
| [STOPSIGNAL](https://docs.docker.com/reference/dockerfile/#stopsignal)            | Specify the system call signal for exiting a container.     |
| [USER](https://docs.docker.com/reference/dockerfile/#user)                        | Set user and group ID.                                      |
| [VOLUME](https://docs.docker.com/reference/dockerfile/#volume)                    | Create volume mounts.                                       |
| [WORKDIR](https://docs.docker.com/reference/dockerfile/#workdir)                  | Change working directory.                                   |

#### Step-24.2.1.2: Lab: Package an Application into a Docker Image (build image)

- Navigate to a sample [Python Flask Application code repository](https://github.com/kbindesh/python-flask-app) and clone it on your Docker Host machine (here, EC2 instance):

```bash
git clone https://github.com/kbindesh/python-flask-app.git

cd python-flask-app

[You will see a sample Python Flask App source code]
```

- Now, in the root of your app directory, create a new file called `Dockerfile`:

```bash
# Create a new file
vi Dockerfile


# Add the following contents to the file

FROM python:3.11-alpine
LABEL maintainer="k.bindesh@gmail.com"
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
EXPOSE 8080
ENTRYPOINT ["python"]
CMD ["src/app.py"]

[Save the file and exit]
```

- Now, it's time to package our Python App into Docker Image by consuming Dockerfile:

```bash
docker image build -t python-flaskapp:amber-bg .

# The preceding command will initiate the image building process


# Now, list Docker Images to verify the newly built image "python-flaskapp:amber-bg"
docker image ls
```

### Step-24.2.2: Interactive Image Creation

- Let's assume that we would like to have a Docker Image with _Alpine OS_ and _curl_ utility. By default, you won't find any built-in image. So, let's build a customized one.

- We start with a base image that we want to use as a template and run a container out of it interactively. Let's say it is _Alpine_ image:

```
docker container run -it --name interactive-img-lab alpine:3.17 /bin/sh

[A new container will be created and you'll land on Container shell]
```

- Now, inside the container run the following command in order to install curl:

```bash
apk update && apk add curl

# The preceding command first updates the "Alpine" package manager, apk, and then it installs the "curl" tool

# Now, you can use curl
curl -I https://google.com
```

- Once you've finished your customization, you can quit the container by typing `exit` at the prompt or pressing `Ctrl + D`.

- Now, if you will list all the containers, you will find our container in _Extited_ state (as /bin/sh process is no more running).

```bash
docker container ls -a
```

- If you want to see what has changed in our container concerning the base image, we can use the docker container diff command:

```bash
# Syntax
docker container diff $CONTAINER_NAME

# Example
docker container diff interactive-img-lab
```

- Now, to persist our modifications
  and create a new image from the above customized container:

```bash
# Syntax
docker container commit $CONTAINER_NAME $IMAGE_NAME

# Example
docker container commit interactive-img-lab alpine-with-curl

# Verify the created image by listing all the images
docker image ls

# To see how our custom image has been built, we can use the history command
docker image history $IMAGE_NAME

docker image history myalpine
```

### Step-24.2.3: Create a Docker Image by importing or loading from a File
