#----------------------
# Variable Definitions
#----------------------
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
      name = "lome-mesh-istio-system-sgp1"
    }
  }
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
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
resource "kubernetes_namespace" "service_mesh" {
  metadata {
    name = "istio-system"
  }
}

#--------------------------------------------------
# Gateway k8s Namespace Configuration (with Istio)
#--------------------------------------------------
resource "kubernetes_namespace" "gateway" {
  metadata {
    name = "gateway"
  }
}

###################################################
#---------REQUIRED COMPONENTS FOR ISTIO-----------#
# Istio Service Mesh Core Installation using Helm #
#-------------------------------------------------#
###################################################
#------------------------------------
# Istio Base Installation using Helm
#------------------------------------
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

#------------------------------------------------------------------
# Istio CNI Plugin Installation using Helm (For Ambient Mode Beta)
#------------------------------------------------------------------
resource "helm_release" "istio_cni" {
  name       = "istio-cni"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "cni"
  version          = "1.23.0"
  namespace        = kubernetes_namespace.service_mesh.metadata.0.name

  set {
    name  = "profile"
    value = "ambient"
  }

  depends_on = [helm_release.istio_base]
}

#---------------------------------------------------------------
# Istio Discovery (Istio Control Plane) Installation using Helm
#---------------------------------------------------------------
resource "helm_release" "istio_control_plane" {
  name       = "istio-control-plane"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.23.0"
  namespace  = kubernetes_namespace.service_mesh.metadata.0.name

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
    value = "mesh-np"
  }

  set {
    name  = "global.istioNamespace"
    value = kubernetes_namespace.service_mesh.metadata.0.name
  }

  set {
    name  = "global.multiCluster.enabled"
    value = "true"
  }

  set {
    name  = "global.multiCluster.clusterName"
    value = "lome-sgp1-dev"
  }

  depends_on = [helm_release.istio_cni]
}

#---------------------------------------------------------------
# Istio zTunnel Installation using Helm (For Ambient Mode Beta)
#---------------------------------------------------------------
resource "helm_release" "istio_ztunnel" {
  name       = "istio-ztunnel"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "ztunnel"
  version          = "1.23.0"
  namespace        = kubernetes_namespace.service_mesh.metadata.0.name

  set {
    #------------------------DO NOT AMEND-----------------------
    # For 1.22, should not change this to global.istioNamespace
    #-----------------------------------------------------------
    name  = "istioNamespace"
    value = kubernetes_namespace.service_mesh.metadata.0.name
  }

  set {
    name  = "multiCluster.clusterName"
    value = "lome-sgp1-dev"
  }
  
  depends_on = [
    helm_release.lome_ingress_sgp1_dev,
    helm_release.lome_egress_sgp1_dev
  ]
}

#----------------------------------------
# Metrics Server Installation using Helm
#----------------------------------------
resource "helm_release" "lome_metrics_server_sgp1_dev" {
  name       = "lome-metrics-server-sgp1-dev"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.8.3"
  namespace  = "kube-system"

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
    value = "networking-np"
  }
}

#################################################################
#---------------------------------------------------------------#
# Istio Service Mesh Networking Control Using Helm & Kubernetes #
#---------------------------------------------------------------#
#################################################################
#----------------------------------------------------------------
# Istio k8s Service Mesh Ingress Gateway Installation using Helm
# - INBOUND Traffic Management, Control & Entry Point
#----------------------------------------------------------------
resource "helm_release" "lome_ingress_sgp1_dev" {
  name       = "lome-ingress-sgp1-dev"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.23.0"
  namespace  = kubernetes_namespace.gateway.metadata.0.name
  timeout = 600

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "nodeSelector.nodepool"
    value = "networking-np"
  }

  depends_on = [helm_release.istio_control_plane]
}

#---------------------------------------------------------------
# Istio k8s Service Mesh Egress Gateway Installation using Helm
# - OUTBOUND Traffic Management, Control & Entry Point
#---------------------------------------------------------------
resource "helm_release" "lome_egress_sgp1_dev" {
  name       = "lome-egress-sgp1-dev"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.23.0"
  namespace  = kubernetes_namespace.gateway.metadata.0.name
  timeout = 600

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "nodeSelector.nodepool"
    value = "networking-np"
  }

  depends_on = [helm_release.istio_control_plane]
}
