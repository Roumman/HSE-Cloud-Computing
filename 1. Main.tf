# Конфигурация автоматически разворачивает ВМ на Ubuntu в Yandex Cloud с предустановленным Plex и даёт доступ по SSH
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud zone"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for access to the VM (format: ssh-rsa AAAA...)"
  type        = string
  sensitive   = true
}

# Provider for yandex cloud
provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

# Сеть и подсеть для ВМ
resource "yandex_vpc_network" "network_1" {
  name = "network_1"
}

resource "yandex_vpc_subnet" "subnet_1" {
  name           = "subnet_1"
  zone           = var.zone
  network_id     = yandex_vpc_network.network_1.id
  v4_cidr_blocks = ["10.2.0.0/24"]
}

# ВМ
resource "yandex_compute_instance" "vm" {
  name        = "terraform-vm"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vhban0amqsqutsjk7" # Ubuntu 24.04 LTS
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_1.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "ubuntu:${var.ssh_public_key}"
    user-data = templatefile("${path.module}/cloud-init-plex.yaml.tpl", {
      script_content_base64 = base64encode(file("${path.module}/scripts/install-plex.sh"))
    })
  }
}

output "ip" {
  description = "Public IP address of the VM"
  value       = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}
