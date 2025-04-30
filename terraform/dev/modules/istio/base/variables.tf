#--------------
# variables.tf
#--------------

variable "istio_namespace" {
  description = "Kubernetes namespace for istio base"
  type        = string
}

variable "name" {
  description = "Specific name for istio base"
  type        = string
}

variable "resource_version" {
  description = "Specific version of istio base"
  type        = string
}