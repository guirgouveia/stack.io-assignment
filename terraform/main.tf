# This section is used to declare the versions and backend configuration for Terraform,
# as well as the providers configuration.
terraform {
  required_version = "=1.6.2"

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.23.0"
    }
  }
}

provider "kubernetes" {
  config_path = ".kube/config"
}

# Path: terraform/variables.tf
# This section is used to declare the variables that will be used in the Terraform configuration.
variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    "app" = "stack-io"
  }
  validation {
    condition     = length(keys(var.labels)) <= 5
    error_message = "Labels must be less than 5"
  }
}

variable "namespace" {
  description = "Namespace to deploy the application to"
  type        = string
  default     = "stack-io"
  validation {
    condition     = length(var.namespace) <= 63
    error_message = "Namespace must be less than 63 characters"
  }
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = "stack-io"
  }
}

# Path: terraform/main.tf
# This section is used to declare the resources that will be created by Terraform.
locals {
  # Read the whole YAML file as a string
  full_yaml = file("${path.root}/../kubernetes/app.yaml")

  # Split the string into a list of YAML documents
  yamls = split("\n---\n", local.full_yaml)

  mysql_yaml = file("${path.root}/../kubernetes/mysql.yaml")

  mysql_manifests = split("\n---\n", local.mysql_yaml)
}

# Create a kubernetes_manifest resource for each YAML document
resource "kubernetes_manifest" "app" {
  for_each = { for idx, yaml in local.yamls : idx => yamldecode(yaml) }

  manifest = each.value
}


resource "kubernetes_manifest" "msql" {
  for_each = { for idx, mysql in local.mysql_manifests : idx => yamldecode(mysql) }

  manifest = each.value
}