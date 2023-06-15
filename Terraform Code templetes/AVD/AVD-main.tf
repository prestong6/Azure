terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#create an resource group 
resource "azurerm_resource_group" "terraform" {
    name = "terraformmain"
    location = var.Azure_region
}

#Networking 
resource "azurerm_virtual_network" "terraform-vnet" {
    name = var.vnet
    resource_group_name = azurerm_resource_group.terraform.name
    location = var.Azure_region
    address_space = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.terraform.name
  virtual_network_name = azurerm_virtual_network.terraform-vnet.name
  address_prefixes     = ["10.0.2.0/24"]

}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            =  var.Azure_region
  resource_group_name = azurerm_resource_group.terraform.name

   ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
}
}
#Vm 

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = var.Azure_region
  resource_group_name   = azurerm_resource_group.terraform.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"
  delete_data_disks_on_termination = true

   storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-core"
    version   = "latest"
  }
  storage_os_disk {
    name              = "disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "notadmin"
    admin_password = "Password1234!"
  }
  os_profile_windows_config {
    provision_vm_agent = true
    }

}
