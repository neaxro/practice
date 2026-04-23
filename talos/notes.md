# Talos OS install for Proxmox

## Requirements

Install talosctl:

```console
curl -sL https://talos.dev/install | sh
# Auto completion
source <(talosctl completion bash)
talosctl completion bash > ~/.talos/completion.bash.inc
	printf "
		# talosctl shell completion
		source '$HOME/.talos/completion.bash.inc'
		" >> $HOME/.bash_profile
	source $HOME/.bash_profile
```

Terraform cli install:

```console
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform
```

### Talos OS

Image schematic ID used during testing `ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515`.
ISO disk image can be downloaded [here](https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.12.6/nocloud-amd64.iso)

Extensions:
```yaml
customization:
    systemExtensions:
        officialExtensions:
            - siderolabs/qemu-guest-agent
```

After downloaded the ISO image follow the documentation: https://docs.siderolabs.com/talos/v1.10/platform-specific-installations/virtualized-platforms/proxmox

#### Env vars

```console
export DISK_IMAGE=ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515
export TALOS_OS_VERSION=v1.12.6
export CONTROL_PLANE_IP=192.168.2.76
export WORKER_IP=192.168.2.77
```

#### First Master Node startup

After boot the node will be in "maintenance mode".

Node IPs:

| Node | IP address |
| ---- | ---------- |
| talos-master-01 | `192.168.2.76` |
| talos-master-02 | `192.168.2.78` |
| talos-worker-01 | `192.168.2.77` |

1. Generate Machine Configs

```console
# Default
talosctl gen config talos-proxmox-cluster https://$CONTROL_PLANE_IP:6443 --output-dir _out
# QEMU Support
talosctl gen config talos-proxmox-cluster https://$CONTROL_PLANE_IP:6443 --output-dir _out --install-image factory.talos.dev/installer/$DISK_IMAGE:$TALOS_OS_VERSION
```

Double check if the disk is correct where the OS will be installed: `talosctl get disks --insecure --nodes $CONTROL_PLANE_IP`
By default it is `/dev/sda`

2. Create Control Plane Node

```console
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file _out/controlplane.yaml
```

> Note: This process can be repeated multiple times to create an HA control plane.

3. Create Worker Node

```console
talosctl apply-config --insecure --nodes $WORKER_IP --file _out/worker.yaml
```

>  Note: This process can be repeated multiple times to add additional workers. 

4. Use the cluster

```console
export TALOSCONFIG="_out/talosconfig"
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $CONTROL_PLANE_IP
```

> These ALL are needed to apply configuration.

5. Bootstrap etcd

```console
talosctl bootstrap
```

6. Retrieve kubeconfig

```console
talosctl kubeconfig .
```