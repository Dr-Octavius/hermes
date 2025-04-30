#----------------------
# main.tf
# - Planned Resources
#----------------------

#------------------------
# Planned Resources
# - resource blocks only
#------------------------
# Kiali Operator instance
resource "helm_release" "eck_operator" {
  name       = var.name
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-operator"
  version          = var.resource_version
  namespace  = var.namespace
  force_update = true
  dependency_update = true

  set {
    name  = "nodeSelector.nodepool"
    value = var.nodepool
  }

  # Add labels here
  set {
    name  = "podLabels.app"
    value = var.name
  }

  set {
    name  = "podLabels.version"
    value = var.resource_version # Set the appropriate version
  }
}