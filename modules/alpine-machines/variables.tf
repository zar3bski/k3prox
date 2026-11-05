variable "proxmox_api" {
  type        = string
  description = "<scheme>://<host>:<port>"
}

variable "proxmox_user" {
  type = string
}

variable "cluster_id" {
  type        = number
  description = "Numerical id of the cluster"
}

variable "vmbr1_cidr" {
  type = string

  validation {
    condition     = can(regex("^\\d{1,3}(\\.\\d{1,3}){3}/\\d{1,2}$", var.vmbr1_cidr))
    error_message = "CIDR block must be in the correct format (e.g., 10.0.0.0/16)."
  }
}

variable "machines_ips" {
  type = map(list(string))
}

variable "proxmox_password" {
  type = string
}

variable "image_url" {
  type        = string
  description = "url of the initial qcow2 image"
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

variable "dns_server" {
  type        = string
  description = "Accessible DNS server in the environment"
}

variable "gateway" {
  type        = string
  description = "Network gateway"
}

