terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "/home/vm2/cloud_terraform/key-sys.json"
  cloud_id  = "b1gs69rim3v9fmomfhdg"
  folder_id = "b1gldou52ac9qqlfs7nq"
  zone      = "ru-central1-a"
}

#Network

resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-1"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = yandex_vpc_network.network.id
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet-2"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  network_id     = yandex_vpc_network.network.id
}


# VM

#vm-ansible
resource "yandex_compute_disk" "boot-disk-ansible" {
  name     = "ansible-hdd"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "10"
  image_id = "fd88bokmvjups3o0uqes"
}

resource "yandex_compute_instance" "vm-ansible" {
  name                      = "vm-ansible"
  allow_stopping_for_update = true
  hostname                  = "vm-ansible.ru-central1.internal"
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"

  resources {
    cores  = "4"
    memory = "4"
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-ansible.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-2.id
    nat                = true
    ip_address         = "192.168.20.13"
    security_group_ids = [yandex_vpc_security_group.ansible-sg.id, yandex_vpc_security_group.vm-sg.id]
  }


  metadata = {
    user-data          = "${file("cloud-init.yaml")}"
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

}

#vm-web1

resource "yandex_compute_disk" "boot-disk-web1" {
  name     = "web1-hdd"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd88bokmvjups3o0uqes"
}

resource "yandex_compute_instance" "vm-web1" {
  name                      = "vm-web1"
  allow_stopping_for_update = true
  hostname                  = "vm-web1.ru-central1.internal"
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"

  resources {
    cores  = "2"
    memory = "2"
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-web1.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-1.id
    nat                = true
    ip_address         = "192.168.10.10"
    security_group_ids = [yandex_vpc_security_group.web-sg.id, yandex_vpc_security_group.vm-sg.id]
  }


  metadata = {
    user-data          = "${file("cloud-init.yaml")}"
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

}

#vm-web2

resource "yandex_compute_disk" "boot-disk-web2" {
  name     = "web2-hdd"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "10"
  image_id = "fd88bokmvjups3o0uqes"
}

resource "yandex_compute_instance" "vm-web2" {
  name                      = "vm-web2"
  allow_stopping_for_update = true
  hostname                  = "vm-web2.ru-central1.internal"
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"

  resources {
    cores  = "2"
    memory = "2"
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-web2.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-2.id
    nat                = true
    ip_address         = "192.168.20.10"
    security_group_ids = [yandex_vpc_security_group.web-sg.id, yandex_vpc_security_group.vm-sg.id]
  }

  metadata = {
    user-data          = "${file("cloud-init.yaml")}"
    serial-port-enable = 1
  }
  scheduling_policy {
    preemptible = true
  }

}

#vm-elk

resource "yandex_compute_disk" "boot-disk-elk" {
  name     = "elk-hdd"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "10"
  image_id = "fd88bokmvjups3o0uqes"
}

resource "yandex_compute_instance" "vm-elk" {
  name                      = "vm-elk"
  allow_stopping_for_update = true
  hostname                  = "vm-elk.ru-central1.internal"
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"

  resources {
    cores  = "4"
    memory = "4"
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-elk.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-2.id
    nat                = true
    ip_address         = "192.168.20.11"
    security_group_ids = [yandex_vpc_security_group.elk-sg.id, yandex_vpc_security_group.vm-sg.id]

  }

  metadata = {
    user-data          = "${file("cloud-init.yaml")}"
    serial-port-enable = 1
  }
  scheduling_policy {
    preemptible = true
  }

}


#vm-zabbix

resource "yandex_compute_disk" "boot-disk-zabbix" {
  name     = "zabbix-hdd"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "10"
  image_id = "fd88bokmvjups3o0uqes"
}

resource "yandex_compute_instance" "vm-zabbix" {
  name                      = "vm-zabbx"
  allow_stopping_for_update = true
  hostname                  = "vm-zabbix.ru-central1.internal"
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"

  resources {
    cores  = "2"
    memory = "2"
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-zabbix.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-2.id
    nat                = true
    ip_address         = "192.168.20.12"
    security_group_ids = [yandex_vpc_security_group.zabbix-sg.id, yandex_vpc_security_group.vm-sg.id]
  }

  metadata = {
    user-data          = "${file("cloud-init.yaml")}"
    serial-port-enable = 1
  }
  scheduling_policy {
    preemptible = true
  }
}


#TG
resource "yandex_alb_target_group" "web-tg" {
  name = "web-tg"

  target {
    subnet_id  = yandex_vpc_subnet.subnet-1.id
    ip_address = "192.168.10.10"
  }

  target {
    subnet_id  = yandex_vpc_subnet.subnet-2.id
    ip_address = "192.168.20.10"
  }

}

#Backend-group


resource "yandex_alb_backend_group" "backend-group" {
  name = "backend-group"

  http_backend {
    name             = "http-backend"
    weight           = 1
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.web-tg.id}"]
    healthcheck {
      timeout  = "1s"
      interval = "1s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}


#HTTP router

resource "yandex_alb_http_router" "web-router" {
  name = "web-router"
}


resource "yandex_alb_virtual_host" "web-virtual-host" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web-router.id
  route {
    name = "route-1"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group.id
        timeout          = "3s"
      }
    }
  }
}

#ALB



resource "yandex_alb_load_balancer" "web-balancer" {
  name       = "web-balancer1"
  network_id = yandex_vpc_network.network.id

  allocation_policy {

    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-1.id
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-2.id
    }


  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web-router.id
      }
    }
  }
}


# Security_groups

#SG vm-sg

resource "yandex_vpc_security_group" "vm-sg" {
  name        = "vm-sg"
  description = "Security groups all vm"
  network_id  = yandex_vpc_network.network.id
}

resource "yandex_vpc_security_group_rule" "rule1" {
  security_group_binding = yandex_vpc_security_group.vm-sg.id
  direction              = "ingress"
  description            = "rule3 description"
  from_port              = 0
  to_port                = 65535
  protocol               = "ANY"
  predefined_target      = "self_security_group"
}

resource "yandex_vpc_security_group_rule" "rule2" {
  security_group_binding = yandex_vpc_security_group.vm-sg.id
  direction              = "egress"
  description            = "rule2 description"
  from_port              = 0
  to_port                = 65535
  protocol               = "ANY"
  predefined_target      = "self_security_group"
}


#SG ansible

resource "yandex_vpc_security_group" "ansible-sg" {
  name        = "ansible-sg"
  description = "Security groups ansible"
  network_id  = yandex_vpc_network.network.id
}
resource "yandex_vpc_security_group_rule" "rule3" {
  security_group_binding = yandex_vpc_security_group.ansible-sg.id
  direction              = "ingress"
  description            = "rule3 description"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  port                   = 22
  protocol               = "TCP"
}

resource "yandex_vpc_security_group_rule" "rule4" {
  security_group_binding = yandex_vpc_security_group.ansible-sg.id
  direction              = "egress"
  description            = "rule4 description"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  protocol               = "ANY"
}




#Web-sg

resource "yandex_vpc_security_group" "web-sg" {
  name        = "web-sg"
  description = "Security groups webservers"
  network_id  = yandex_vpc_network.network.id

}

resource "yandex_vpc_security_group_rule" "rule5" {
  security_group_binding = yandex_vpc_security_group.web-sg.id
  direction              = "ingress"
  description            = "rule5 description"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  port                   = 80
  protocol               = "TCP"
}

resource "yandex_vpc_security_group_rule" "rule6" {
  security_group_binding = yandex_vpc_security_group.web-sg.id
  direction              = "egress"
  description            = "rule6 description"
  from_port              = 0
  to_port                = 65535
  v4_cidr_blocks         = ["0.0.0.0/0"]
  protocol               = "ANY"

}



# Zabbix-sg

resource "yandex_vpc_security_group" "zabbix-sg" {
  name        = "zabbix-sg"
  description = "Security groups zabbix"
  network_id  = yandex_vpc_network.network.id
}

resource "yandex_vpc_security_group_rule" "rule7" {
  security_group_binding = yandex_vpc_security_group.zabbix-sg.id
  direction              = "ingress"
  description            = "rule7 description"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  port                   = 8080
  protocol               = "TCP"
}

resource "yandex_vpc_security_group_rule" "rule8" {
  security_group_binding = yandex_vpc_security_group.zabbix-sg.id
  direction              = "egress"
  description            = "rule8 description"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  protocol               = "ANY"
}



# ELK-sg
resource "yandex_vpc_security_group" "elk-sg" {
  name        = "elk-sg"
  description = "Security groups ELK"
  network_id  = yandex_vpc_network.network.id
}

resource "yandex_vpc_security_group_rule" "rule9" {
  security_group_binding = yandex_vpc_security_group.elk-sg.id
  direction              = "ingress"
  description            = "rule9 description"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  port                   = 5601
  protocol               = "TCP"
}

resource "yandex_vpc_security_group_rule" "rule10" {
  security_group_binding = yandex_vpc_security_group.elk-sg.id
  direction              = "egress"
  description            = "rule10 description"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  protocol               = "ANY"
}



# snapshot

resource "yandex_compute_snapshot_schedule" "snapshot" {
  name = "snapshot"

  schedule_policy {
    expression = "10 0 ? * *"
  }

  snapshot_count   = 7
  retention_period = "168h"

  snapshot_spec {
    description = "vms-disk-snapshot"
  }
  disk_ids = ["${yandex_compute_disk.boot-disk-ansible.id}", "${yandex_compute_disk.boot-disk-web1.id}", "${yandex_compute_disk.boot-disk-web2.id}", "${yandex_compute_disk.boot-disk-elk.id}", "${yandex_compute_disk.boot-disk-zabbix.id}"]

}

