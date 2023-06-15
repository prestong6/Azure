variable "resource_group_location" {
  default     = "West US"
  description = "Location of the resource group - West US"
}

variable "rg_name" {
  type        = string
  default     = "AVD-Test-RG"
  description = "Name of the Resource group in which to deploy service objects"
}

variable "workspace" {
  type        = string
  description = "Name of the Azure Virtual Desktop workspace"
  default     = "AVD-Test-WS"
}

variable "hostpool" {
  type        = string
  description = "Name of the Azure Virtual Desktop host pool"
  default     = "AVD-HOSTPOOL"
}

variable "app_group_name" {
  description = "Name of the Azure Virtual Desktop application group"
  type        = string
  default     = "AVD-app"
}

variable "rfc3339" {
  type        = string
  default     = "2023-06-20T12:43:13Z" #Update this value with a future date
  description = "Registration token expiration"
}

variable "prefix" {
  type        = string
  default     = "AVD-"
  description = "Prefix of the name of the AVD machine(s)"
}

variable "tags" {
  type    = map(string)
  default = {
    Environment = "Dev"
    Department  = "IT"
    Location = "West US"
    ServiceClass = "DEV"
    Workload = "Host Pool 01"
  }
}

data "azuread_client_config" "AzureAD" {}

data "azuread_group" "AVDGroup" {
  display_name     = "Win365-Users"  
}
