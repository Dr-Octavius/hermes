#--------------
# variables.tf
#--------------

variable "istio_namespace" {
  description = "Kubernetes namespace for istio components"
  type        = string
}

variable "nodepool" {
  description = "Kubernetes nodepool for istio gateway"
  type        = string
}

variable "name" {
  description = "Specific name for istio gateway"
  type        = string
}

variable "resource_version" {
  description = "Specific version of istio gateway"
  type        = string
}