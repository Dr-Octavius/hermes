#----------------------
# main.tf
# - Planned Resources
#----------------------

#------------------------
# Planned Resources
# - resource blocks only
#------------------------
# ECK Operator instance
resource "helm_release" "eck_stack" {
  name              = var.name
  repository        = "https://helm.elastic.co"
  chart             = "eck-operator"
  version           = var.resource_version
  namespace         = var.namespace
  force_update      = true
  dependency_update = true
  set {
    name  = "nodeSelector.nodepool"
    value = var.nodepool
  }
  set {
    name = "managedNamespaces"
    value = jsonencode({
      (var.namespace) = true
    })
  }
  # Add labels here
  set {
    name  = "podLabels.app"
    value = var.name
  }
  set {
    name  = "podLabels.version"
    value = var.resource_version
  }
}