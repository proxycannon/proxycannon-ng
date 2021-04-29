# This file contains the variables the user needs to provide

## Default Server Count for Exit Nodes
variable "server_count" {
    default = 2
}

# key-file should be the full location of the private key used for the VPS of choice
variable "key-file" {
	default = ""
}

# name should be set to the name of the public key onfile with your provider
variable "sshName" {
		default = ""
}

variable "awsAccessKey" {
	default = ""
}

variable "awsSecretKey" {
	default = ""
}

variable "isAWS" {
    type = bool
    default = false
}
