#--------------
# variables.tf
#--------------

variable "username" {
  description = "Username for Kiali Dashboard"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Password for Kiali Dashboard"
  type        = string
  sensitive   = true
}

variable "namespace" {
  description = "Kubernetes namespace for Kiali Operator"
  type        = string
}

variable "nodepool" {
  description = "Kubernetes nodepool for Kiali Operator"
  type        = string
}

variable "name" {
  description = "Specific name for Kiali Operator"
  type        = string
}

variable "resource_version" {
  description = "Specific version of Kiali Operator"
  type        = string
}