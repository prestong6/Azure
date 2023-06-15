# Resource group name is output when execution plan is applied.
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.resource_group_location
  tags = var.tags
}

resource "azurerm_virtual_network" "Vnet-AVD"{
  name = "Vnet-AVD"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = ["10.0.0.0/16"]
  subnet {
    name = "avd-subnet"
    address_prefix = "10.0.3.0/24"
  }
}

# Create AVD workspace
resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = var.workspace
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  friendly_name       = "${var.prefix} Workspace"
  description         = "${var.prefix} Workspace"
  tags = var.tags
}

# Create AVD host pool
resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  name                     = var.hostpool
  friendly_name            = var.hostpool
  validate_environment     = true #[true false]
  start_vm_on_connect      = true
  custom_rdp_properties    = "targetisaadjoined:i:1;drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:1;enablerdsaadauth:i:1;"
  description              = "${var.prefix} HostPool"
  type                     = "Personal" #[Pooled or Personal]
  personal_desktop_assignment_type = "Automatic"
  load_balancer_type       =  "Persistent"
  tags = var.tags
scheduled_agent_updates {
  enabled = true
  timezone = "Eastern Standard Time"  # Update this value with your desired timezone
  schedule {
    day_of_week = "Saturday"
    hour_of_day = 1   #[1 here means 1:00 am]
  }
}
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = var.rfc3339
}

# Create AVD DAG
resource "azurerm_virtual_desktop_application_group" "dag" {
  resource_group_name = azurerm_resource_group.rg.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.hostpool.id
  location            = azurerm_resource_group.rg.location
  type                = "Desktop"
  name                = var.app_group_name
  friendly_name       = "Desktop AppGroup"
  description         = "${var.prefix} AVD application group"
  depends_on          = [azurerm_virtual_desktop_host_pool.hostpool, azurerm_virtual_desktop_workspace.workspace]
  tags = var.tags
}

# Associate Workspace and DAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
}

# Assign AAD Group to the Desktop Application Group (DAG)
resource "azurerm_role_assignment" "AVDGroupDesktopAssignment" {
  scope                = azurerm_virtual_desktop_application_group.dag.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = data.azuread_group.AVDGroup.object_id
}

# Assign AAD Group to the Resource Group for RBAC for the Session Host
resource "azurerm_role_assignment" "RBACAssignment" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = data.azuread_group.AVDGroup.object_id
}

