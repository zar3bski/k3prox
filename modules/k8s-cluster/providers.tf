terraform {
  required_providers {
    ansible = {
      version = "~> 1.4.0"
      source  = "ansible/ansible"
    }
    random = {
      source  = "opentofu/random"
      version = "3.9.1"
    }
  }
}
