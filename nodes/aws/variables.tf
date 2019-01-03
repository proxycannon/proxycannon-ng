variable "aws_priv_key" {
  default = "~/.ssh/proxycannon.pem"
}

# number of exit-node instances to launch
variable "count" {
  default = 2
}

# AMI image to use for exit nodes
variable "ami" {
  default = "ami-0f65671a86f061fcd"
}

# Size of EC2 VM to spin up for exit nodes
variable "size" {
  default = "t2.micro"
}

variable "allowedips" {
  default = [
    "CONTROLSERVERPUBLICIP/32",
    "CONTROLSERVERPRIVATEIP/32"
  ]
}

# launch all exit nodes in the same subnet id
# this should be the same subnet id that your control server is in
# you can get this value from the AWS console when viewing the details of the control-server instance
variable "subnet_id" {
  default = "subnet-XXXXXXXX"
}
