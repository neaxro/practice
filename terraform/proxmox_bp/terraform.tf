terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure     = true
  pm_api_url          = "https://tc:8006/api2/json"
  pm_api_token_id     = "terraform@pam!bp_testing"
  pm_api_token_secret = "bde25676-7c27-47a9-a563-be954e261294"
  pm_user             = "terraform"
  pm_otp              = ""
}
