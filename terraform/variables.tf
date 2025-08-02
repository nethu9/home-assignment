variable "subscription_id" {}

variable "address_space" {
  default = ["10.0.0.0/16"]
}

variable "size" {
  default = "Standard_B1s"
}

variable "location" {
  default = "France Central"
}

variable "vm_name" {
  default = "tallinn-temperature"
}

variable "admin_username" {
  default = "azureuser"
}

variable "app" {
  default = "temperature"
}
variable "ssh_public_key" {}
