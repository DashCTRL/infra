# Infra

Infra is a collection of tools and scripts to manage my home infrastructure.

## Terraform

### Setup

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint


echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt-get install terraform
terraform -install-autocomplete
```

### Usage

```bash
cd terraform/proxmox/clone
terraform init
terraform plan
terraform apply
```


### Proxmox

[https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/guides/cloud_init](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/guides/cloud_init)
[https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu#provision-through-cloud-init](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu#provision-through-cloud-init)
[https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-connection-via-username-and-api-token](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-connection-via-username-and-api-token)
[https://yetiops.net/posts/proxmox-terraform-cloudinit-saltstack-prometheus/#creating-a-template](https://yetiops.net/posts/proxmox-terraform-cloudinit-saltstack-prometheus/#creating-a-template)
[http://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.qcow2](http://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.qcow2)


### Create User

```bash
pveum user add terraform@pve --password terraform
```

### Create API Token

```bash
pveum aclmod / -user terraform@pve -role PVEAdmin

pveum passwd terraform@pve -token-id terraform -token-value terraform
```

### Create SSH Key

```bash

ssh-keygen -t rsa -b 4096 -C "terraform@pve"

ssh-copy-id -i ~/.ssh/id_rsa.pub terraform@pve
```