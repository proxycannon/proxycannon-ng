terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "us-east-2"
    access_key = var.awsAccessKey
    secret_key = var.awsSecretKey
}

resource "aws_security_group" "proxycannon-sec-group" {
  name = "proxycannon-sec-group"

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }
  ingress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "exit-node" {
  # This evaluates if var.isAWS is true. If true then sets count to
  # var.server_count but if it runs false it sets it to 0
  count = var.isAWS ? var.server_count : 0
  ami = "ami-09b0e7e86badffe0e"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.proxycannon-sec-group.id]
  key_name = var.sshName
  source_dest_check = false

  tags = {
    Name = "cannon-exit${count.index}"
  }

  provisioner "file" {
    source      = "${path.module}/configs/node/"
    destination = "/tmp"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key-file)
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    script = "${path.module}/configs/node/node_setup.bash"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key-file)
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> ${path.module}/configs/command/node_addresses.txt"
  }
}

resource "aws_instance" "command-node" {
  count = var.isAWS ? 1 : 0
  ami = "ami-09b0e7e86badffe0e"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.proxycannon-sec-group.id]
  key_name = var.sshName
  source_dest_check = false

  tags = {
    Name = "cannon-command"
  }

  depends_on = [
    aws_instance.exit-node,
  ]

  provisioner "file" {
    source = "${path.module}/configs/command/"
    destination = "/tmp"

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file(var.key-file)
      host = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/command_setup.bash",
      "sudo /tmp/command_setup.bash 2",
      "sudo chmod +x /tmp/add_route.bash",
      "cat /tmp/node_addresses.txt | while read line; do sudo /tmp/add_route.bash $line; done",
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file(var.key-file)
      host = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "scp -i ${var.key-file} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${self.public_ip}:/tmp/conpack.tar.gz ${path.module}/"
  }
}
