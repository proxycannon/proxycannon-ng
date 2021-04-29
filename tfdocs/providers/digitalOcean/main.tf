terraform {
    required_providers {
        digitalocean = {
            source = "digitalocean/digitalocean"
            version = "~>1.22.2"
        }
    }
}

provider "digitalocean" {
    token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
    name = var.sshName
}

resource "digitalocean_droplet" "exit-node" {
  count	= var.isDO ? var.server_count : 0
  name = "cannon-exit${count.index}"

  image = "ubuntu-20-04-x64"
  region = "nyc3"
  size = "s-1vcpu-1gb"
  private_networking = true
  vpc_uuid = "9884658b-dc84-11e8-80bc-3cfdfea9fba1" # default nyc-3 vpc

  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  tags = [
    "proxycannon",
    "exit-node"
  ]

  provisioner "file" {
    source      = "${path.module}/configs/node/"
    destination = "/tmp"

    connection {
      type     = "ssh"
      user     = "root"
      private_key = file(var.key-file)
      host = self.ipv4_address
    }
  }

  # execute our provisioning scripts
  provisioner "remote-exec" {
    script = "${path.module}/configs/node/node_setup.bash"

    connection {
      type     = "ssh"
      user     = "root"
      private_key = file(var.key-file)
      host = self.ipv4_address
    }
  }

  provisioner "local-exec" {
    command = "echo ${self.ipv4_address_private} >> ${path.module}/configs/command/node_addresses.txt"
  }
}

resource "digitalocean_droplet" "command-node" {
  count = var.isDO ? 1 : 0
  name = "cannon-command0"

  image = "ubuntu-20-04-x64"
  region = "nyc3"
  size = "s-1vcpu-1gb"
  private_networking = true
  vpc_uuid = "9884658b-dc84-11e8-80bc-3cfdfea9fba1" # default nyc-3 vpc

  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  tags = [
    "proxycannon",
    "command-node"
  ]

  depends_on = [
    digitalocean_droplet.exit-node,
  ]

  provisioner "file" {
    source      = "${path.module}/configs/command/"
    destination = "/tmp"

    connection {
      type     = "ssh"
      user     = "root"
      private_key = file(var.key-file)
      host = self.ipv4_address
    }
  }

  # modify our route table when we bring up an exit-node
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/command_setup.bash",
      "/tmp/command_setup.bash 1",
      "chmod +x /tmp/add_route.bash",
      "cat /tmp/node_addresses.txt | while read line; do /tmp/add_route.bash $line; done",
    ]

    connection {
      type = "ssh"
      user = "root"
      private_key = file(var.key-file)
      host = self.ipv4_address
    }
  }

  # modify our route table when we destroy an exit-node
  provisioner "local-exec" {
    command = "scp -i ${var.key-file} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${self.ipv4_address}:/tmp/conpack.tar.gz ${path.module}/"
  }
}
