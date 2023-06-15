variable "Azure_region" {
  type = string
  default = "West US"
}
variable "prefix" {
  default = "TestVM"
}
variable "vnet" {
  type = string 
  default = "terraform-vnet"
}
variable "ARG" {
  type = string
  default = "terraform"
  
}
