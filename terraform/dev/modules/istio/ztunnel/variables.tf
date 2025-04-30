#--------------
# variables.tf
#--------------

variable "cluster_name" {
  description = "Kubernetes cluster for istio ztunnel"
  type        = string
}

variable "istio_namespace" {
  description = "Kubernetes namespace for istio components"
  type        = string
}

variable "name" {
  description = "Specific name for istio ztunnel"
  type        = string
}

variable "resource_version" {
  description = "Specific version of istio ztunnel"
  type        = string
}