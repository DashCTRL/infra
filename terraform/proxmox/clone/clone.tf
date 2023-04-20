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
    vm_name      = "ubuntu-22.04-docker"
    node_name    = "pve"
    iso_storage  = "local"
    vm_storage   = "local-lvm"
    vm_disk_size = "20G"
    domain       = var.domain
    ssh_pub_key  = file("~/.ssh/id_rsa.pub")
}

resource "proxmox_vm_qemu" "vm" {
    name        = local.vm_name
    target_node = local.node_name
    count = 1

    clone            = "ubuntu-cloud"
    full_clone       = true
    onboot           = true
    agent            = 1
    scsihw           = "virtio-scsi-pci"
    memory           = 2048
    cores            = 2
    sockets          = 1
    cpu              = "host"
    ipconfig0        = "ip=dhcp"
    sshkeys          = local.ssh_pub_key


    network {
        model     = "virtio"
        bridge    = "vmbr0"
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
            "echo 'printenv'",
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
