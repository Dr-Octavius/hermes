#----------------------
# main.tf
# - Local Expressions
# - Created Resources
# - Planned Resources
# - Referenced Configs
#----------------------

#----------------------
# Common Expressions
# - locals blocks only
#----------------------
locals {
  namespace = "efk-system"
  nodepool  = "core-np"
}

#--------------------
# Created Resources
# - data blocks only
#--------------------
# Destination Cluster for EFK stack
data "digitalocean_kubernetes_cluster" "dev_cluster" {
  name = "sefire-sgp1-dev"
}

#------------------------
# Planned Resources
# - resource blocks only
#------------------------
# Destination namespace for EFK stack
resource "kubernetes_namespace" "efk" {
  metadata {
    name = local.namespace
  }
}

#----------------------
# Referenced Configs
# - module blocks only
#----------------------
# Module Config for ECK Operator
module "eck" {
  source           = "modules/kiali-operator" # where to reference module
  namespace        = local.namespace          # Set the target namespace to place pod in
  nodepool         = local.nodepool           # Set the target nodepool to place pod in
  name             = "eck-operator"           # Set the appropriate name
  resource_version = "3.0.0"                  # Set the appropriate version
}