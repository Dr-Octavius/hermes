#--------------
# variables.tf
#--------------

variable "namespace" {
  description = "Kubernetes namespace for metrics server"
  type        = string
}

variable "nodepool" {
  description = "Kubernetes nodepool for metrics server"
  type        = string
}

variable "name" {
  description = "Specific name for metrics server"
  type        = string
}

variable "resource_version" {
  description = "Specific version of metrics server"
  type        = string
}