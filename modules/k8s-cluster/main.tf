resource "ansible_group" "all" {
  name     = "all"
  children = []
  variables = {
    vip_v4 = {
      address = "${var.vip_v4}"
      gateway = "${var.gateway}"
    }
  }
}

resource "random_password" "k3s_enrolment_token" {
  length  = 16
  special = false
}

resource "random_password" "vrrp_password" {
  length  = 16
  special = false
}

resource "random_integer" "keepalived_router_id" {
  min = 1
  max = 255
}

resource "ansible_playbook" "site" {
  for_each = tomap({
    "${var.hosts_ips[0]}" : ["lb", "cp"],
    "${var.hosts_ips[1]}" : ["lb", "cp"],
    "${var.hosts_ips[2]}" : ["cp"]
  })
  playbook   = "../../playbooks/site.yml"
  name       = each.key
  replayable = true
  verbosity  = 2
  groups     = concat(["all"], each.value)
  extra_vars = {
    ansible_become           = true
    ansible_become_method    = "doas"
    ansible_ssh_common_args  = "-o StrictHostKeyChecking=accept-new"
    ansible_user             = "${var.admin_username}"
    broadcast                = "${var.broadcast}"
    dns_server               = "${var.dns_server}"
    gateway                  = "${var.gateway}"
    haproxy_exporter_port    = 9101
    k3s_enrolment_token      = random_password.k3s_enrolment_token.result
    k3s_version              = "v1.36"
    keepalived_exporter_port = 9102
    node_exporter_port       = 9100
    router_id                = random_integer.keepalived_router_id.id
    vip_v4                   = "${var.vip_v4}"
    vrrp_master              = var.hosts_ips[0]
    vrrp_password            = random_password.vrrp_password.result
  }
}

