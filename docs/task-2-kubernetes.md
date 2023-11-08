# Task 2 Implementation: Kubernetes

This is the implementation for the second task of the assignment, which consists of deploying the Dockerized app to a Kubernetes cluster.

For this implementation, a kubernetes Golang package was created for the server to handle the Kubernetes readiness and liveness probes, as well as the lifecycle hooks requests.

In addition to the requirements, the following features were implemented:

- Created a *skaffold.yaml* file to automate the build and deployment process to Kubernetes.
- Added Security Context to Pods and Containers to improve security and manage permissions.
- Added termination grace period to allow the app to gracefully shutdown, considering the time needed to finish the preStop Hook.
- Added a init container to change file permissions of the postStart and preStop hook scripts.
- Mounted the scripts as ConfigMap volumes to allow the app to execute them.
- Added resources requests and limits to the Pod to improve performance and resource management.
- Added Ingrees to expose the app to the outside world.
- Uses the image from my personal Docker Hub registry.
- Added network policies to restrict access to the app.
- Added persistent volume claims to allow data persistence.
- Added RBAC to restrict access, giving only the necessary permissions to the app.
- Added a MySQL database manifest with the `mysql.yaml` file.

# Getting Started

This tutorial will show you how to deploy and expose the app to a local minikube Kubernetes cluster.

## Prerequisites

- [minikube](https://minikube.sigs.k8s.io/docs/start/) (version 1.22.0 or later)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (version 1.22.0 or later)
- [skaffold](https://skaffold.dev/docs/install/) (version 1.31.0 or later) ( optional )
- [Go](https://golang.org/dl/) (version 1.21.2 or later) ( optional )
- [Docker](https://www.docker.com/products/docker-desktop) ( optional )

The optional tools are only needed if you want to build the Docker image locally and run it with Skaffold. If you're using the image from my personal Docker Hub registry, you can skip this step.

Furthermore, Skaffold is only needed if you want to automate the build and deployment process to Kubernetes.

## Usage

### Starting the Kubernetes Cluster

To start the Kubernetes cluster, run the following command:

```
    minikube start
```

This command will start a local Kubernetes cluster using the Docker container runtime.

### Deploying the App

To build and deploy the app to the Kubernetes cluster, navigate to the [kubernetes](./kubernetes) run the following command:

As kubectl doesn't resolve dependencies between files, and the namespace.yaml is created in a separate file, we need to apply it first, and then apply the rest of the resources. 
```
    kubectl apply -f ./namespace.yaml 
```
   

This command will create all the necessary Kubernetes resources to run the app, including the MySQL database.
```
    kubectl apply -f .
```

A better approach would be to declare all the related resources in the same file or use a tool like Kustomize to create a single file with all the resources, as you can see in my [kubernetes-deployments](github.com/guirgouveia/kubernetes-deployments) repository, where I further explore multiple-options to deploy apps to Kubernetes.