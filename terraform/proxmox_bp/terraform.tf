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
  pm_api_token_id     = "..."
  pm_api_token_secret = "..."
  pm_user             = "terraform"
  pm_otp              = ""
}
