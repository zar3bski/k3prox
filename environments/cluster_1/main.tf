# Guide le plus complet sur la structuration de projets
# https://burakdede.com/blog/mastering-multi-environment-terraform-strategies-from-the-trenches/#the-strategies
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

locals {
  image_url  = "https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/cloud/alpine-3.23.7-x86_64-bios-cloudinit-r0.qcow2"
  vmbr0_base = regex("(\\d+\\.\\d+\\.\\d+).*", var.vmbr0_cidr)
  vmbr1_base = format("192.168.2%01d", var.cluster_id)
  machines_ips = tomap({
    "${var.cluster_id}01" : ["${local.vmbr0_base[0]}.${var.cluster_id}1/24", "${local.vmbr1_base}.1/24"],
    "${var.cluster_id}02" : ["${local.vmbr0_base[0]}.${var.cluster_id}2/24", "${local.vmbr1_base}.2/24"],
    "${var.cluster_id}03" : ["${local.vmbr0_base[0]}.${var.cluster_id}3/24", "${local.vmbr1_base}.3/24"]
  })
  hosts_ips = [
    "${local.vmbr0_base[0]}.${var.cluster_id}1",
    "${local.vmbr0_base[0]}.${var.cluster_id}2",
    "${local.vmbr0_base[0]}.${var.cluster_id}3"
  ]

}

# https://registry.terraform.io/providers/bpg/proxmox/latest
provider "proxmox" {
  endpoint = var.proxmox_api
  username = var.proxmox_user
  password = var.proxmox_password
  insecure = true # FIXME: variabiliser
}


module "alpine-machines" {
  source           = "../../modules/alpine-machines/"
  cluster_id       = var.cluster_id
  machines_ips     = local.machines_ips
  admin_username   = var.admin_username
  admin_password   = var.admin_password
  ssh_keys         = var.ssh_keys
  image_url        = local.image_url
  proxmox_api      = var.proxmox_api
  proxmox_user     = var.proxmox_user
  proxmox_password = var.proxmox_password
  vmbr1_cidr       = "${local.vmbr1_base}.0/24"
  dns_server       = var.dns_server
  gateway          = var.gateway
  node_name        = var.node_name
}



resource "null_resource" "next" {
  depends_on = [module.alpine-machines]

  for_each = toset(local.hosts_ips)
  provisioner "local-exec" {
    command = <<EOF
      echo "waiting for VMs" &&
      timeout=0 &&
      while [ $(($timeout<600)) ]; do
        ssh -o StrictHostKeyChecking=accept-new ${var.admin_username}@${each.value}
        if [ $? == 0 ]; then
           echo "${each.value} reached"
           break
        fi
        sleep 30
        timeout=$((timeout+30))
      done
    EOF

  }
}

module "k8s-cluster" {
  depends_on     = [module.alpine-machines, null_resource.next]
  source         = "../../modules/k8s-cluster/"
  admin_username = var.admin_username
  admin_password = var.admin_password
  vip_v4         = "${local.vmbr0_base[0]}.${var.cluster_id}0"
  dns_server     = var.dns_server
  broadcast      = var.broadcast
  gateway        = var.gateway
  hosts_ips      = local.hosts_ips
}
