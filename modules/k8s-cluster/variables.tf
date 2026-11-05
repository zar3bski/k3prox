variable "admin_username" {
  type        = string
  description = "name of the default wheel user"
  default     = "admin"
}

variable "admin_password" {
  type = string
}

variable "vip_v4" {
  type = string
}

variable "dns_server" {
  type        = string
  description = "Accessible DNS server in the environment"
}

variable "gateway" {
  type        = string
  description = "Network gateway"
}

variable "broadcast" {
  type        = string
  description = "Network broadcast"
}

variable "hosts_ips" {
  type        = list(string)
  description = "IPs of the machine to run the playbook on"
}
