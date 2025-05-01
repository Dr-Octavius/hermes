#--------------
# variables.tf
#--------------

variable "cluster_name" {
  description = "Kubernetes cluster for istio discovery plane"
  type        = string
}

variable "istio_namespace" {
  description = "Kubernetes namespace for istio components"
  type        = string
}

variable "nodepool" {
  description = "Kubernetes nodepool for istio discovery plane"
  type        = string
}

variable "name" {
  description = "Specific name for istio discovery plane"
  type        = string
}

variable "resource_version" {
  description = "Specific version of istio discovery plane"
  type        = string
}