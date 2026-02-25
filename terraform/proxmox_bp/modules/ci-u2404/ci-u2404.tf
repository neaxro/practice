terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

resource "proxmox_vm_qemu" "ci-u2404" {
  name        = "tf-${var.name}-${count.index + 1}"
  description = "VM for testing Terraform provisioning"
  target_node = "tc"

  count = var.instance_count

  clone      = "ci-u2404"
  full_clone = true

  memory = var.memory
  cpu {
    cores   = var.cpu_cores
    sockets = 1
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot   = "order=scsi0"
  scsihw = "virtio-scsi-pci"


  # Root disk
  disk {
    slot    = "scsi0"
    size    = var.root_disk_size
    type    = "disk"
    storage = "local-lvm"
  }

  # Cloud-init disk
  disk {
    slot    = "ide2"
    type    = "cloudinit"
    storage = "local-lvm"
  }

  serial {
    id   = 0
    type = "socket"
  }

  agent   = 1
  os_type = "cloud-init"

  ipconfig0  = "ip=dhcp"
  ciupgrade  = true
  ciuser     = "axel2"
  cipassword = "Asdasd11"
}
