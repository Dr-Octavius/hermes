#--------------
# variables.tf
#--------------

variable "istio_namespace" {
  description = "Kubernetes namespace for istio components"
  type        = string
}

variable "name" {
  description = "Specific name for istio cni"
  type        = string
}

variable "resource_version" {
  description = "Specific version of istio cni"
  type        = string
}