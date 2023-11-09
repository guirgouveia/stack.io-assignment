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
  type        = map(map(string))
  default = {
    stack-io = {
      app = "stack-io"
    }
    mysql = {
      app = "mysql"
    }
  }
}

variable "namespaces" {
  description = "Namespaces to create"
  type        = map(string)
  default = {
    stack-io = "stack-io"
    mysql    = "mysql"
  }
  validation {
    condition     = alltrue([for k, v in var.namespaces : length(v) <= 63])
    error_message = "Namespace must be less than 63 characters"
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

# Create a kubernetes_namespace resource for each namespace
resource "kubernetes_namespace" "namespaces" {
  for_each = var.namespaces

  metadata {
    name   = each.value
    labels = var.labels[each.key]
  }
}

# Create a kubernetes_manifest resource for each YAML document
resource "kubernetes_manifest" "app" {
  for_each = { for idx, yaml in local.yamls : idx => yamldecode(yaml) }

  manifest = each.value

  depends_on = [kubernetes_namespace.namespaces]
}


resource "kubernetes_manifest" "msql" {
  for_each = { for idx, mysql in local.mysql_manifests : idx => yamldecode(mysql) }

  manifest = each.value

  depends_on = [kubernetes_namespace.namespaces]
}