terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# https://registry.terraform.io/providers/bpg/proxmox/latest
provider "proxmox" {
  endpoint = var.proxmox_api
  username = var.proxmox_user
  password = var.proxmox_password
  insecure = true # FIXME: variabiliser
}
