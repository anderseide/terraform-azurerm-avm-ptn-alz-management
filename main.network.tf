resource "azurerm_resource_group" "management_virtual_network" {
  count = var.management_virtual_network_enabled ? 1 : 0

  location = var.location
  name = var.management_virtual_network_resource_group_name != null ? var.management_virtual_network_resource_group_name : "rg-management-vnet-${var.location}"
  tags     = var.tags
}

module mgmt_virtual_network {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version  = "0.9.2"

  count = var.management_virtual_network_enabled ? 1 : 0

  location = var.location
  name = var.management_virtual_network_name
  address_space = var.management_virtual_network_address_space
  resource_group_name = azurerm_resource_group.management_virtual_network[0].name

}
