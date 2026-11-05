variable "proxmox_api" {
  type        = string
  description = "<scheme>://<host>:<port>"
}

variable "proxmox_user" {
  type = string
}

variable "proxmox_password" {
  type = string
}

variable "node_name" {
  type        = string
  description = "Name on the node in the proxmox cluster"
  default     = "proxmox"
}

variable "admin_username" {
  type        = string
  description = "name of the default wheel user"
  default     = "admin"
}

variable "admin_password" {
  type = string
}

variable "ssh_keys" {
  type        = list(string)
  description = "SSH keys for default admin"
}

variable "vmbr0_cidr" {
  type = string
  validation {
    condition     = can(cidrnetmask("${var.vmbr0_cidr}"))
    error_message = "Invalid ip v4 CIDR"
  }
}

variable "cluster_id" {
  type = string
  validation {
    condition     = tonumber(var.cluster_id) == floor(var.cluster_id)
    error_message = "cluster_id should be an integer!"
  }
  validation {
    condition     = var.cluster_id > 0 && var.cluster_id < 25
    error_message = "Expected 0 < $cluster_id < 25!"
  }
}

variable "dns_server" {
  type        = string
  description = "Accessible DNS server in the environment"
  validation {
    condition     = can(cidrnetmask("${var.dns_server}/32"))
    error_message = "Invalid ip v4"
  }
}

variable "gateway" {
  type        = string
  description = "Network gateway"
  validation {
    condition     = can(cidrnetmask("${var.gateway}/32"))
    error_message = "Invalid ip v4"
  }
}

variable "broadcast" {
  type        = string
  description = "Network broadcast"

  validation {
    condition     = can(cidrnetmask("${var.broadcast}/32"))
    error_message = "Invalid ip v4"
  }
}
