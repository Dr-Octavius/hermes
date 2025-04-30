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
  namespace = "istio-system"
  nodepool  = "core-np"
  size_4_8    = "s-4vcpu-8gb"
}

#--------------------
# Created Resources
# - data blocks only
#--------------------
# Destination Cluster for EFK stack
data "digitalocean_kubernetes_cluster" "cluster" {
  name = "sefire-sgp1-dev"
}

#--------------------------------------------------------
# Planned Resources
# - resource blocks only
# - place here if speed is prioritised; modularise later
#--------------------------------------------------------

#----------------------
# Referenced Configs
# - module blocks only
#----------------------
# Module Config for istio-system namespace
module "istio" {
  source    = "./modules/kubernetes/namespace" # where to reference module
  namespace = local.namespace                  # Set the target namespace to be created
}

# Module Config for standalone Jaeger nodepool
module "jaeger_np" {
  source     = "./modules/kubernetes/nodepool"
  cluster_id = data.digitalocean_kubernetes_cluster.cluster.id
  name       = "jaeger-np"
  size       = local.size_4_8
  auto_scale = true
  min_nodes  = 1
  max_nodes  = 3
}

# Module Config for dedicated Prometheus nodepool
module "prometheus_np" {
  source     = "./modules/kubernetes/nodepool"
  cluster_id = data.digitalocean_kubernetes_cluster.cluster.id
  name       = "prometheus-np"
  size       = local.size_4_8
  auto_scale = true
  min_nodes  = 1
  max_nodes  = 3
}

# Module Config for ECK Operator
module "kiali" {
  source           = "modules/kiali-operator" # where to reference module
  namespace        = local.namespace          # Set the target namespace to place pod in
  nodepool         = local.nodepool           # Set the target nodepool to place pod in
  name             = "kiali-operator"           # Set the appropriate name
  resource_version = "2.8.0"                  # Set the appropriate version
}