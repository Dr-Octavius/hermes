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
module "namespace" {
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

# Module Config for Kiali Operator
module "kiali_operator" {
  source           = "modules/kiali-operator" # where to reference module
  namespace        = local.namespace          # Set the target namespace to place pod in
  nodepool         = local.nodepool           # Set the target nodepool to place pod in
  name             = "kiali-operator"           # Set the appropriate name
  resource_version = "2.8.0"                  # Set the appropriate version
  password = ""
  username = ""
  depends_on = [module.namespace]
}

# Module Config for istio base
module "istio_base" {
  source           = "modules/istio/base" # where to reference module
  istio_namespace        = local.namespace          # Set the target namespace to place pod in
  name             = "istio-base"           # Set the appropriate name
  resource_version = "1.26.0-rc.0"                  # Set the appropriate version
  depends_on = [module.namespace]
}

# Module Config for istio cni
module "istio_cni" {
  source           = "modules/istio/cni" # where to reference module
  istio_namespace        = local.namespace          # Set the target namespace to place pod in
  name             = "istio-cni"           # Set the appropriate name
  resource_version = "1.26.0-rc.0"                  # Set the appropriate version
  depends_on = [module.istio_base]
}

# Module Config for istiod
module "istiod" {
  source           = "modules/istio/istiod" # where to reference module
  istio_namespace        = local.namespace          # Set the target namespace to place pod in
  name             = "istiod"           # Set the appropriate name
  resource_version = "1.26.0-rc.0"                  # Set the appropriate version
  cluster_name = data.digitalocean_kubernetes_cluster.cluster.name
  nodepool     = local.nodepool
  depends_on = [module.istio_cni]
}

# Module Config for network ingress gateway
module "ingress" {
  source           = "modules/istio/gateway" # where to reference module
  istio_namespace        = local.namespace          # Set the target namespace to place pod in
  name             = "ingress"           # Set the appropriate name
  resource_version = "1.26.0-rc.0"                  # Set the appropriate version
  nodepool = local.nodepool
  depends_on = [module.istiod]
}

# Module Config for network egress gateway
module "egress" {
  source           = "modules/istio/gateway" # where to reference module
  istio_namespace        = local.namespace          # Set the target namespace to place pod in
  name             = "egress"           # Set the appropriate name
  resource_version = "1.26.0-rc.0"                  # Set the appropriate version
  nodepool = local.nodepool
  depends_on = [module.istiod]
}

# Module Config for network egress gateway
module "ztunnel" {
  source           = "modules/istio/ztunnel" # where to reference module
  istio_namespace        = local.namespace          # Set the target namespace to place pod in
  name             = "egress"           # Set the appropriate name
  resource_version = "1.26.0-rc.0"                  # Set the appropriate version
  cluster_name = data.digitalocean_kubernetes_cluster.cluster
  depends_on = [module.istiod]
}