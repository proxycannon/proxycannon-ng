# This file contains the variables the user needs to provide

## Default Server Count for Exit Nodes
variable "server_count" {
    default = 2
}

# key-file should be the full location of the private key used for the provider
variable "key-file" {
	default = ""
}

# name should be set to the name of the public key onfile with the provider
variable "sshName" {
		default = ""
}

# Digital Ocean token
variable "do_token" {
    default = ""
}

variable "isDO" {
    type = bool
    default = false
}
