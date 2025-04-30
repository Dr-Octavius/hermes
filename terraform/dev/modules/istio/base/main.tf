#----------------------
# main.tf
# - Planned Resources
#----------------------

#------------------------
# Planned Resources
# - resource blocks only
#------------------------
# Istio Base Installation using Helm
resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  version          = "1.23.0"
  namespace        = kubernetes_namespace.service_mesh.metadata.0.name
  create_namespace = true

  set {
    name  = "global.istioNamespace"
    value = kubernetes_namespace.service_mesh.metadata.0.name
  }
}