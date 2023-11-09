# Getting Started

This module will guide you through the basics of how to create a Terraform script to deploy a Kubernetes application.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Provider

The main.tf file declares a Kubernetes provider configured to connect to your minikube context, using a local .kube/config file.

If you have multiple clusters on your kubeconfig file, isolate the minikube context, user and cluster information from it to a new file, using the following command:

```
  kubectl config view --minify --flatten --context=minikube > ./kube/config
```

## Deploying the application

As the exercise explicitly tells to use the Kubernetes Provider to deploy the `app.yaml` file from the previous exercise, we will need to split the file into multiple files, because it contains multiple resource declarations and the provider's resource that accepts yaml files as arguments ( `kubernetes_manifest` ), only accepts yaml files with single resource declaration. 

This was done using terraform built-in functions and local variables, as you can see below:

```
  # Path: terraform/main.tf
  # This section is used to declare the resources that will be created by Terraform.

  locals {
    # Read the whole YAML file as a string
    full_yaml = file("${path.root}/../kubernetes/app.yaml")

    # Split the string into a list of YAML documents
    yamls = split("\n---\n", local.full_yaml)
  }

  # Create a kubernetes_manifest resource for each YAML document
  resource "kubernetes_manifest" "app" {
    for_each = { for idx, yaml in local.yamls : idx => yamldecode(yaml) }

    manifest = each.value
  }
```

This workaround creates multiple `kubernetes_manifest` resources from a single yaml file.

The `kubectl provider` could also be used to deploy the whole manifest at once, but it also has some limitations. The best approach would still be declaring each resource separatedly, or creating Helm charts using the `helm provider`.

I did the same for MySQL, so everything is deployed together.