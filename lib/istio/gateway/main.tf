#----------------------
# main.tf
# - Planned Resources
#----------------------

#------------------------
# Planned Resources
# - resource blocks only
#------------------------
# Istio Base Installation using Helm
resource "helm_release" "gateway" {
  name       = var.name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = var.resource_version
  namespace  = var.istio_namespace
  timeout = 600

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "nodeSelector.nodepool"
    value = var.nodepool
  }
}