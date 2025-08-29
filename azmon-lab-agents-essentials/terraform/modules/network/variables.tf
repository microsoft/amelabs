variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_name" {
  type    = string
  default = "vmss_subnet"
  description = "Name of the subnet"
}

variable "my_ip" {
  type = string
}
