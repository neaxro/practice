export VM_ID=9001

# create a new VM
qm create $VM_ID --memory 1024 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --name ci-u2404
qm set $VM_ID --scsi0 local-lvm:0,import-from=/root/noble-server-cloudimg-amd64.img
qm resize $VM_ID scsi0 10G

# Setup cloud init
qm set $VM_ID --ide2 local-lvm:cloudinit
qm set $VM_ID --boot order=scsi0
qm set $VM_ID --cicustom "user=local:snippets/ci-u2024.yaml"
qm set $VM_ID --serial0 socket --vga serial0

qm template $VM_ID