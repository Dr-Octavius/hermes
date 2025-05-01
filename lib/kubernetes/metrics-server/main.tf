#----------------------
# main.tf
# - Planned Resources
#----------------------

#------------------------
# Planned Resources
# - resource blocks only
#------------------------
# Istio Base Installation using Helm
resource "helm_release" "metrics" {
  name       = var.name
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.resource_version
  namespace  = var.namespace

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  set {
    name  = "args[1]"
    value = "--metric-resolution=30s"
  }

  set {
    name  = "nodeSelector.nodepool"
    value = var.nodepool
  }
}