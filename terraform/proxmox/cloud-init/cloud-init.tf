terraform {
    required_providers {
        proxmox = {
        source  = "Telmate/proxmox"
        version = "~> 2.9.14"
        }
    }
}

provider "proxmox" {
    pm_api_url   = var.pm_api_url
    pm_user      = var.pm_user
    pm_password  = var.pm_password
    pm_tls_insecure = var.pm_tls_insecure
    pm_debug = true
    pm_log_enable = true
    pm_log_file   = "terraform-plugin-proxmox.log"
    pm_log_levels = {
        _default    = "debug"
        _capturelog = ""
    }
}

locals {
    vm_name      = "cloud-init-ubuntu-22.04-docker"
    node_name    = "pve"
    iso_storage  = "local"
    vm_storage   = "local-lvm"
    vm_disk_size = "20G"
    domain       = var.domain
    ssh_pub_key  = file("~/.ssh/id_rsa.pub")
}

data "template_file" "cloud_init" {
    template = file("/home/antoine/code/antoine/.infra/terraform/proxmox/cloud-init/cloud-init.tmpl")

    vars = {
        ssh_key_pub  = file("~/.ssh/id_rsa.pub")
        vm = local.vm_name
        domain   = local.domain
    }
}

resource "local_file" "cloud-init" {
    content  = data.template_file.cloud_init.rendered
    filename = "/home/antoine/code/antoine/.infra/terraform/proxmox/cloud-init/cloud-init.yml"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "cloud-init" {
    connection {
        type    = "ssh"
        user    = var.pm_user
        private_key = file("~/.ssh/id_rsa")
        host    = var.pm_api_url
    }

    provisioner "file" {
        source       = local_file.cloud-init.filename
        destination  = "/var/lib/vz/snippets/cloud-init.yml"
    }
}


resource "proxmox_vm_qemu" "vm" {
    count         = 1
    name          = local.vm_name
    target_node   = local.node_name
    iso           = "${local.iso_storage}:iso/ubuntu-22.10-minimal-cloudimg-amd64.img"
    bootdisk      = "scsi0"
    onboot        = true
    agent         = 1
    scsihw        = "virtio-scsi-pci"
    memory        = 2048
    cores         = 2
    sockets       = 1
    cpu           = "host"
    ipconfig0     = "ip=dhcp"
    sshkeys       = file("~/.ssh/id_rsa.pub")
    cicustom = "user=local:snippets/cloud-init.yml,disable"


    network {
        model     = "virtio"
        bridge    = "vmbr0"
    }

    lifecycle {
        ignore_changes = [
            network
        ]
    }

    disk {
        type         = "scsi"
        storage      = local.vm_storage
        size         = local.vm_disk_size
        cache        = "writeback"
        format       = "raw"
    }

    provisioner "remote-exec" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
        ]

    connection {
        type        = "ssh"
        host        = self.ipconfig0
        user        = "ubuntu"
        private_key = file("~/.ssh/id_rsa")
        }
    }
}

output "vm_ipv4_address" {
    value = proxmox_vm_qemu.vm.*.ipconfig0
}

output "ssh_instructions" {
    value = "To SSH into the VM, use the following command: ssh -i <PATH_TO_YOUR_SSH_PRIVATE_KEY> ubuntu@${proxmox_vm_qemu.vm.0.ipconfig0 != null ? proxmox_vm_qemu.vm.0.ipconfig0 : "UNKNOWN_IP"}"
}
