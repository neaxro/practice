terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
  name        = "tf-${var.name}-${count.index + 1}"
  description = "VM for testing Terraform provisioning"
  target_node = "tc"

  count = var.instance_count

  clone      = "ci-u2404-basic"
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
  ciuser     = "axel"
  cipassword = "Asdasd11"
  sshkeys    = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkoawvCBBV/eRY17Zkv440xtWKbcjwT+yrZr3kVWa/Z6dtPd58S/WZ5FZ5sWVkzr78P7hZJiHxU4ISmNEANcJFOMz5X1LF+gSfk0Qkba431Qq0I6ODODNCcCo90no/P0ml0kyhcqNPkfH8WIlcYpQ3w0PV9q0bM3xDDP/HVXlYzSzz0xLOS/Vqjqa2AbUXQdIdtPszuSaw+DFbaTg2wVQIAegzF3tzlj/qEE8gsMd7dQ2S/FZXp1Nr1lGFI3ZeGhy66F75o7ysa46ua7sHZJYCpdDs9wX2coQRams95aSTwnIlSbjZE72oo2SMrNV4JKsPe23/db6Yi6LEb3p7zF9bDV/HPjhZeiGdEd66najWsLAuIgoYabTdmI/4q6NZMflnvcIQeD646Q5Bof4Y02ldixqZ8iodzHd+4FRWbztb/wQZvTiqPvcSDpwUmrBklmgnNao0s+tZShZfask+Y3R2M192cwkMKIImQysbBZvuKI/NgO5oiqqgS6cvZLdQchE= axel@ubuntu
  EOF
}
