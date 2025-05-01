#----------------------
# main.tf
# - Planned Resources
#----------------------

#------------------------
# Planned Resources
# - resource blocks only
#------------------------
# Istio Base Installation using Helm
resource "helm_release" "d" {
  name       = var.name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = var.resource_version
  namespace  = var.istio_namespace

  set {
    name  = "profile"
    value = "ambient"
  }

  set {
    name  = "pilot.enabled"
    value = "true"
  }

  set {
    name  = "pilot.autoscaleEnabled"
    value = "true"
  }

  set {
    name  = "pilot.autoscaleMin"
    value = "1"
  }

  set {
    name  = "pilot.autoscaleMax"
    value = "2"
  }

  set {
    name  = "pilot.nodeSelector.nodepool"
    value = var.nodepool
  }

  set {
    name  = "global.istioNamespace"
    value = var.namespace
  }

  set {
    name  = "global.multiCluster.enabled"
    value = "true"
  }

  set {
    name  = "global.multiCluster.clusterName"
    value = var.cluster_name
  }
}