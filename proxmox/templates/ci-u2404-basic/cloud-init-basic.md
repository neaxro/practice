# Basic cloud-init template creation

According to the [documentation](https://pve.proxmox.com/wiki/Cloud-Init_Support#_preparing_cloud_init_templates), but modified VM ID handling.

```console
apt-get install cloud-init
```

```console
# download the image
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
```

```console
export VM_ID=9000

# create a new VM with VirtIO SCSI controller
qm create $VM_ID --memory 2048 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci

# import the downloaded disk to the local-lvm storage, attaching it as a SCSI drive
qm set $VM_ID --scsi0 local-lvm:0,import-from=/path/to/bionic-server-cloudimg-amd64.img

# resize disk for root filesystem.
qm resize $VM_ID scsi0 32G
```

> `local-lvm:0` means that allocate as much storage space as much is needed. Depends on the image file.
> Better to expand the VM's storage for future usage.

**Add Cloud-Init CD-ROM drive**

The next step is to configure a CD-ROM drive, which will be used to pass the Cloud-Init data to the VM.

```console
qm set $VM_ID --ide2 local-lvm:cloudinit
```

To be able to boot directly from the Cloud-Init image, set the boot parameter to order=scsi0 to restrict BIOS to boot from this disk only. This will speed up booting, because VM BIOS skips the testing for a bootable CD-ROM.

```console
qm set $VM_ID --boot order=scsi0
```

For many Cloud-Init images, it is required to configure a serial console and use it as a display. If the configuration doesn’t work for a given image however, switch back to the default display instead.

```console
qm set $VM_ID --serial0 socket --vga serial0
```

In a last step, it is helpful to convert the VM into a template. From this template you can then quickly create linked clones. The deployment from VM templates is much faster than creating a full clone (copy).

```console
qm template $VM_ID
```
