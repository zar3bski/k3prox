#https://registry.terraform.io/providers/bpg/proxmox/latest/docs

resource "proxmox_download_file" "alpine_qcow2" {
  content_type        = "import"
  file_name           = "${var.cluster_id}-alpine3.24.1.qcow2"
  datastore_id        = "local"
  node_name           = var.node_name
  url                 = var.image_url
  overwrite           = true
  overwrite_unmanaged = true
}

resource "proxmox_network_linux_bridge" "vmbr1" {
  node_name  = var.node_name
  name       = "vmbr${var.cluster_id}"
  address    = var.vmbr1_cidr
  comment    = "vmbr1: Internal cluster communication"
  vlan_aware = true
  vids       = "2-4094"
}

# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm
resource "proxmox_virtual_environment_vm" "node" {
  for_each  = var.machines_ips
  node_name = var.node_name
  vm_id     = each.key
  name      = "node${substr(each.key, -1, 1)}"

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  keyboard_layout = "fr"

  initialization {
    dns {
      servers = ["${var.dns_server}"]
    }
    ip_config {
      ipv4 {
        address = each.value[0]
        gateway = var.gateway
      }
    }
    ip_config {
      ipv4 {
        address = each.value[1]
      }
    }
    user_account {
      keys     = var.ssh_keys
      password = var.admin_password
      username = var.admin_username
    }
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_download_file.alpine_qcow2.id
    interface    = "scsi0"
    size         = 10
  }

  network_device {
    bridge = "vmbr0"
  }

  network_device {
    bridge = proxmox_network_linux_bridge.vmbr1.name
    model  = "e1000e"
  }

}
