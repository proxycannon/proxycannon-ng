variable "aws_priv_key" {
  default = "~/.ssh/proxycannon.pem"
}

# number of exit-node instances to launch
variable "count" {
  default = 2
}

variable "ami" {
  default = "ami-0f65671a86f061fcd"
}
variable "size" {
  default = "t2.micro"
}

# launch all exit nodes in the same subnet id
# this should be the same subnet id that your control server is in
# you can get this value from the AWS console when viewing the details of the control-server instance
variable "subnet_id" {
  default = "subnet-XXXXXXXX"
}
