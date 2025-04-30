#----------------------
# main.tf
# - Planned Resources
#----------------------

#------------------------
# Planned Resources
# - resource blocks only
#------------------------
# Istio Base Installation using Helm
resource "helm_release" "ztunnel" {
  name       = var.name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "ztunnel"
  version          = var.resource_version
  namespace        = var.istio_namespace

  set {
    #------------------------DO NOT AMEND-----------------------
    # For 1.22, should not change this to global.istioNamespace
    #-----------------------------------------------------------
    name  = "istioNamespace"
    value = var.istio_namespace
  }

  set {
    name  = "multiCluster.clusterName"
    value = var.cluster_name
  }
}