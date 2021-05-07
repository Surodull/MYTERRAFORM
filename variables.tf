variable "resourcegroup_name" {
  description = "Enter the name of the Resource Group:"
  type        = string
}

variable "vnet_name" {
  description = "Enter the name of the Virtual network:"
  type        = string
}

variable "subnet1_name" {
  description = "Enter the name of Subnet1:"
  type        = string
}

variable "subnet2_name" {
  description = "Enter the name of Subnet2:"
  type        = string
}

variable "subnet3_name" {
  description = "Enter the name of Subnet3:"
  type        = string
}

variable "nsg_name" {
  description = "Enter the name of Network Security Group:"
  type        = string
}

variable "vm_name" {
  description = "Enter the name of Virtual Machine:"
  type        = string
}

variable "vm_username" {
  description = "Enter the Username of Virtual Machine:"
  type        = string
}

variable "vm_password" {
  description = "Enter the Password to access Virtual Machine:"
  type        = string
}

variable "mysql_name" {
  description = "Enter the Name for MySQL Server:"
  type        = string
}

variable "mysql_username" {
  description = "Enter the Username for MySQL Database:"
  type        = string
}

variable "mysql_password" {
  description = "Enter the Password for MySQL Database:"
  type        = string
}

variable "mysql_dbname" {
  description = "Enter the Name for MySQL Database to be created:"
  type        = string
}

variable "privatevm_name" {
  description = "Enter the Name of the Private VM to be created:"
  type        = string
}

variable "privatevm_username" {
  description = "Enter the Username of Private Virtual Machine:"
  type        = string
}

variable "privatevm_password" {
  description = "Enter the Password to accessPrivate Virtual Machine:"
  type        = string
}