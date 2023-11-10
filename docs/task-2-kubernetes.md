# Task 2 Implementation: Kubernetes

This is the implementation for the second task of the assignment, which consists of deploying the Dockerized app to a Kubernetes cluster.

For this implementation, a kubernetes Golang package was created for the server to handle the Kubernetes readiness and liveness probes, as well as the lifecycle hooks requests.

In addition to the requirements, the following features were implemented:

- Created a *skaffold.yaml* file to automate the build and deployment process to Kubernetes.
- Added a MySQL database manifest with the `mysql.yaml` file.
- Added Security Context to Containers to improve security and manage permissions.
- Added termination grace period to allow the app to gracefully shutdown, considering the time needed to finish the preStop Hook.
- Added a init container to change file permissions of the postStart and preStop hook scripts.
- Mounted the readiness, liveness probe and lifecycle hook scripts as ConfigMap volumes to allow the app to execute them.
- Added resources requests and limits to the Pod to improve performance and resource management.
- Added Ingrees to expose the app to the outside world.
- Added network policies to restrict access to the app.
- Added persistent volume claims to allow data persistence.
- Added RBAC to restrict access, giving only the necessary permissions to the app.

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

### Loading images into Minikube

Now, you need to build the image using minikube, because it uses a different Docker daemon than the one running on your machine.

```
minikube build -t stack-io ./dockerize
```

The imagePullPolicy was then configured to "IfNotPresent" in the templates, to avoid pulling the image from the Docker Hub registry.

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

A better approach would be to declare all the related resources in the same file or use Skaffold or Kustomize that creates a dependendecy logic between the files, as you can see in my [kubernetes-deployments](github.com/guirgouveia/kubernetes-deployments) repository, where I further explore multiple-options to deploy apps to Kubernetes.

### Running with Skaffold

To create a local CICD pipeline, you can use Skaffold to automate the build and deployment process to Kubernetes.

To run the app with Skaffold, run the following command:

```
    skaffold dev
```

Skaffold will rebuild the image and redeploy upon changes to the source code or template files.

Skaffold automatically uses the minikube Docker daemon, so the image will already be present in the cluster.

### Accessing the App

Three types of services were created for the app:

- ClusterIP: to expose the app to other resources inside the cluster.
- NodePort: to expose the app to a port on the node running minikube ( localhost ).
- LoadBalancer: to expose the app to the outside world.

In addition, a Ingress resource was created to expose the app with [NGINX Ingress Controller](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwiQn8W3v7WCAxXPqJUCHU7RBOMQFnoECAUQAQ&url=https%3A%2F%2Fdocs.nginx.com%2Fnginx-ingress-controller%2F&usg=AOvVaw2lebwrv0Wvgj3YPSasaSWF&opi=89978449).


To use the ingress, add the minikube ingress addon with:

```
    minikube addons enable ingress
```

Enable the ingress tunnel with:

```
    minikube tunnel
```

And finally, add the following line to your `/etc/hosts` file:
```
    127.0.0.1       stack-io.local
```

Remember to close the tunnel, when you're done, with `Ctrl+C`.

The application should be accessible at:

- `http://$(minikube ip):30080`, where 30080 is the port exposed by the NodePort service. This approach is only recommended for local deployments, as it exposes the cluster port directly to the outside world.

- `http://localhost:89`, where 80 is the port exposed by the Load Balancer service and also at `http://stack-io.local`, using the Ingress. This approach is recommended for production deployments.

- `http://localhost:8083`by Skaffold. This approach is only recommended for local deployments, as it exposes the cluster port directly to the outside world.
