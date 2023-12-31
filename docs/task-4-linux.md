# Task 4 Implementation: Linux

This is the implementation for the fourth task of the assignment, which consists of automating the process of bumping the image version and rendering a new Kubernetes manifest file with that new version.

For this implementation, a Bash script was created to automate the process of building the Docker image, tagging it with a new version, and rendering a new Kubernetes manifest file with the new image version.

In addition to the requirements, the script will create a new semver tag, if it doesn't exist, and push the image to a Docker registry, if the --push flag is set.

# Getting Started

Simply run the `automation.sh` script and wait for the output.

It will build the Docker image, tag it with a new semantic version, and render a new Kubernetes manifest file with the new image version, comparing the changes with the previous version.

It already uses the Minikube Docker Daemon, so don't worry about that.