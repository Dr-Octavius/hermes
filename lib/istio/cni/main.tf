#----------------------
# main.tf
# - Planned Resources
#----------------------

#------------------------
# Planned Resources
# - resource blocks only
#------------------------
# Istio Base Installation using Helm
resource "helm_release" "cni" {
  name       = var.name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "cni"
  version          = var.resource_version
  namespace        = var.istio_namespace

  set {
    name  = "profile"
    value = "ambient"
  }
}