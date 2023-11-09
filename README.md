# Introduction

This is a candidate assessment assignment from [Stack.io](https://www.stack.io). A consulting firm focused in DevOps. Read the [Guideline](#guideline) section containing the tasks to be completed.

You can find documentation for the implementation of each task at [docs](https://github.com/guirgouveia/stack.io-assignment/tree/main/docs):

- [Task 1: Dockerize](github.com/guirgouveia/stack.io-assignment/tree/main/docs/task-1-dockerize.md)
- [Task 2: Kubernetes](github.com/guirgouveia/stack.io-assignment/tree/main/docs/task-2-kubernetes.md)
- [Task 3: Terraform](github.com/guirgouveia/stack.io-assignment/tree/main/docs/task-3-terraform.md)
- [Task 4: Linux](github.com/guirgouveia/stack.io-assignment/tree/main/docs/task-4-linux.md)

All the commands and scripts were tested using my personal Docker registry, so you may need to change or leave the registry address blank in the following files:

- `kubernetes/app.yaml`
- `linux/automation.sh`
- `linux/script.yaml`
- `dockerize/.env`

Furthermore, the Kubernetes templates are using the image from my personal Docker registry, so you may need to change the image address in the `kubernetes/app.yaml` and `linux/script.yaml` files.

# Guideline

### **Provided by Stack.io**

Welcome to our `Take Home Assignment`. We are going to provide you with a sequence of tasks to be executed:

* [Task 1](dockerize): Dockerize a simple golang webserver; You do not need to modify or write any golang code. You do not need to be familiar with the golang language either, just with how to manipulate and use an already written golang app.
* [Task 2](kubernetes): Deploy that docker image to your local k8s cluster following the given spec
* [Task 3](terraform): Create a terraform module
* [Task 4](linux): Write down a shell script for further automation

