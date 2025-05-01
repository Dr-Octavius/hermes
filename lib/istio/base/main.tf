#----------------------
# main.tf
# - Planned Resources
#----------------------

#------------------------
# Planned Resources
# - resource blocks only
#------------------------
# Istio Base Installation using Helm
resource "helm_release" "base" {
  name             = var.name
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  version          = var.resource_version
  namespace        = var.istio_namespace
  create_namespace = true

  set {
    name  = "global.istioNamespace"
    value = var.istio_namespace
  }
}