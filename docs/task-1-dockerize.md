# Task 1 Implementation: Dockerize

This is the implementation for the first task of the assignment, which consists of dockerizing a simple Golang webserver.

Additionally to the requirements, the following features were implemented:

- The Dockerfile uses a multi-stage build to create a small Docker image.
- A `docker-compose.yaml` file containing all the dependencies and configurations needed to build and run the app is provided.
- A *server.confi* and a *mysql-init.sh* config files are provided to configure the MySQL server connection.
- A Kubernetes Handler Golang package was created to handle future Kubernetes events, such as the ones triggered by the Kubernetes liveness, readiness probes and the lifecycle hooks.
- Start the server in a goroutine so that it doesn't block the main thread.
- Pushes the image my personal Docker Hub registry and use it.

## MySQL Server

The app requires a MySQL Server running, so use the provided [Kubernetes templates](./kubernetes/mysql) or the `docker-compose.yaml` file in the `dockerize` directory, which sets up necessary services, environment variables, and user privileges.

An initial *blog* database is created for storing blog posts, but it's empty as no content is provided by the assigner. 

The Docker Compose file also sets up volumes for data and log persistence, and demonstrates passing environment variables using Dockerfile ARGs and ENVs instructions. The environment variables passed in the Docker Compose file are defined in the .env file.

# Getting Started

This repository contains a Go webserver that is designed to be run inside a Docker container.

## Prerequisites

- [Go](https://golang.org/dl/) (version 1.21.2 or later)
- [Docker](https://www.docker.com/products/docker-desktop)
- [Docker Compose](https://docs.docker.com/compose/install/linux/) (optional)

## Usage

Before building the Docker image, make sure to tidy up the Go modules from the [dockerize](./dockerize) directory:

```bash
go mod tidy
```

This command will ensure that your `go.mod` and `go.sum` files are up to date, in case you have added any new dependencies.

### Building the Docker Image

To build the Docker image, navigate to the [dockerize](./dockerize) directory containing the `Dockerfile` and run:

```bash
docker build -t stack-io .
```

This command builds a Docker image and tags it as `stack-io`.

### Running the Docker Container

To run the Docker container, use the following command:

```bash
docker run -p 8080:8080 stack-io
```

This command runs the Docker container and maps the port 8080 inside the Docker container to port 8080 on your local machine.

Now, you can access the webserver at `http://localhost:8080`, but it will break very soon, because the app requires a MySQL Server running, hence, it is more convenient to run the app using Docker Compose, as explained in the next section.

### Running with Docker Compose

To satisfy the dependencies on other services, such as a MySQL server, a Docker Compose file is provided for your convenience. It builds and runs the app, as well as the MySQL server and Adminer, and sets up the necessary environment variables, network and volumes.

An *.env* file is provided to set the environment variables used by the Docker Compose file. The environment variables are used to set the image name and tag, the MySQL server connection parameters, as well as the MySQL root password and the Adminer password.


To build the image and run the app using Docker Compose, navigate to the `dockerize` directory containing the `docker-compose.yaml` file and run:

```bash
docker-compose up --build
```

Now, you can access the webserver at `http://localhost:8081`, because the docker-compose file maps port 8080 inside the Docker container to port 8081 on your local machine to avoid conflicts with services running on port 8080.

Remember to change the IMAGE_TAG environment variable in the .env file to ensure you are running a the correct version of the image in your stack, or leave it as "latest" to use the latest built version.

The image can also be built and pushed to a Docker registry, such as Docker Hub, to be used by the Kubernetes cluster in the next task, with:

```
docker-compose build --push
```

Remember to change the IMAGE_TAG environment variable in the .env file to your Docker Hub username, so that you can push the image to your Docker Hub account. Furthermore, the IMAGE_NAME environment variable is currently set to my own Docker Registry, so change it accordingly, if you want to push the image to your own Docker Registry or use local images.

### About the Docker Image

A Multi-stage build is used to create a small Docker image. The Dockerfile contains two stages:

- The builder stage builds the Go binary.
- The runner stage copies only the Go binary from the builder stage and runs it.
- The final stage is based on a slim Debian image that contains only the bare minimum to run the Go binary.

Furthermore, the following configurations are applied:

- The Dockerfile installs the certificates for the CA certificates and curl in the final stage. This is required to make HTTPS calls.
- The Dockerfile includes a HEALTHCHECK with curl to check if the webserver is running.
- The Dockerfile removes the apt cache to reduce the image size. This is done in the same layer as the apt-get install command to reduce the image size.
- The Dockerfile sets:
  -  the timezone to UTC to avoid issues with timezones.
  - the locale to en_US.UTF-8 to avoid issues with locales.
    - These configurations increase the size of the final image in 15Mb, so they can be removed if necessary.
  - the default shell to */bin.sh* to avoid issues with shells.