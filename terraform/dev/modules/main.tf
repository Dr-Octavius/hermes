#----------------------
# Variable Definitions
#----------------------
variable "kiali_username_sgp1_dev" {
  description = "Username for Kiali Dashboard"
  type        = string
  sensitive   = true
}

variable "kiali_password_sgp1_dev" {
  description = "Password for Kiali Dashboard"
  type        = string
  sensitive   = true
}

variable "do_token" {
  description = "Digital Ocean API token"
  type        = string
  sensitive   = true
}

#-------------------------------
# Terraform Cloud Configuration
#-------------------------------
terraform {
  cloud {
    organization = "SEFIRE"

    workspaces {
      name = "lome-mesh-monitoring-sgp1"
    }
  }
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.39.2"
    }
  }
}

#------------------------
# Provider Configuration
#------------------------
provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_kubernetes_cluster" "lome_sgp1_dev" {
  name = "lome-sgp1-dev"
}

provider "helm" {
  kubernetes {
    host  = data.digitalocean_kubernetes_cluster.lome_sgp1_dev.endpoint
    token = data.digitalocean_kubernetes_cluster.lome_sgp1_dev.kube_config.0.token
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.lome_sgp1_dev.kube_config.0.cluster_ca_certificate
    )
  }
}

provider "kubernetes" {
  host  = data.digitalocean_kubernetes_cluster.lome_sgp1_dev.endpoint
  token = data.digitalocean_kubernetes_cluster.lome_sgp1_dev.kube_config.0.token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.lome_sgp1_dev.kube_config.0.cluster_ca_certificate
  )
}

#-----------------------------------
# Istio k8s Namespace Configuration
#-----------------------------------
resource "kubernetes_namespace" "mesh_monitoring" {
  metadata {
    name = "mesh-monitoring"
    labels = {
      "istio.io/dataplane-mode" = "ambient"
    }
  }
}

#-------------------------------------------------
# Kiali Operator Installation using Helm
# - Recommended for Installation Into Production
#-------------------------------------------------
resource "helm_release" "eck_operator" {
  name       = "kiali-operator"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-operator"
  version          = "1.89.0"
  namespace  = kubernetes_namespace.mesh_monitoring.metadata.0.name
  force_update = true
  dependency_update = true

  set {
    name  = "nodeSelector.nodepool"
    value = "monitoring-np"
  }

  # Add labels here
  set {
    name  = "podLabels.app"
    value = "kiali-operator"
  }

  set {
    name  = "podLabels.version"
    value = "1.89.0"  # Set the appropriate version
  }
}