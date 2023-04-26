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
}

locals {
    template_name = "ubuntu-template"
    node_name     = "pve"
    iso_storage   = "local"
    iso_file      = "ubuntu-22.04.1-custom-amd64.iso" # Change this line to use the custom ISO
    vm_storage    = "local-lvm"
    vm_disk_size  = "20G"
    ssh_pub_key   = file("~/.ssh/id_rsa.pub")
}

resource "null_resource" "prepare_iso" {
    provisioner "local-exec" {
    command = "./prepare_template.sh"
    }
    triggers = {
        always_run = timestamp()
    }
}

resource "proxmox_vm_qemu" "template" {
    depends_on = [null_resource.prepare_iso]
    name        = local.template_name
    target_node = local.node_name
    iso         = "${local.iso_storage}:${local.iso_file}"

    memory   = 2048
    cores    = 2
    sockets  = 1
    cpu      = "host"

    network {
        model  = "virtio"
        bridge = "vmbr0"
    }

    disk {
        type    = "scsi"
        storage = local.vm_storage
        size    = local.vm_disk_size
        cache   = "writeback"
        format  = "qcow2"
    }

    lifecycle {
        ignore_changes = [
            network,
            disk,
        ]
    }
    # Add the remote-exec provisioner to install Docker and Docker Compose
    provisioner "remote-exec" {
        inline = [
            "until ping -c1 ${self.ipconfig0} &>/dev/null; do sleep 1; done", # Wait for the VM to be reachable
            "sudo apt-get update",
            "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
            "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
            "sudo apt-get update",
            "sudo apt-get install -y docker-ce",
            "sudo systemctl enable docker",
            "sudo systemctl start docker",
            "sudo curl -L \"https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
            "sudo chmod +x /usr/local/bin/docker-compose",
            "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose"
        ]

        connection {
            type        = "ssh"
            host        = self.ipconfig0
            user        = "root"
            private_key = file("~/.ssh/id_rsa")
        }
    }
}

resource "null_resource" "ubuntu_install" {
    provisioner "local-exec" {
    command = <<EOT
        echo "SSH into the template VM and install Ubuntu using the following command:"
        echo "ssh -i ~/.ssh/id_rsa root@${proxmox_vm_qemu.template.ipconfig0}"
        echo "Once the installation is complete, convert the VM to a template in the Proxmox web interface."
    EOT
}
}
