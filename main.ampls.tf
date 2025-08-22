resource "azurerm_resource_group" "azure_monitor_private_link_scope" {
  count = var.azure_monitor_private_link_scope_enabled ? 1 : 0

  location = var.location
  name     = var.azure_monitor_private_link_scope_resource_group_name
  tags     = var.tags
}


resource "azurerm_monitor_private_link_scope" "azure_monitor_private_link_scope" {
  count = var.azure_monitor_private_link_scope_enabled ? 1 : 0

  name = var.azure_monitor_private_link_scope_name
  resource_group_name = azurerm_resource_group.azure_monitor_private_link_scope[0].name
  tags = var.tags

  ingestion_access_mode = var.azure_monitor_private_link_scope_ingestion_access_mode
  query_access_mode = var.azure_monitor_private_link_scope_query_access_mode
}

module "avm-res-network-privateendpoint" {
  source  = "Azure/avm-res-network-privateendpoint/azurerm"
  version = "0.2.0"

  count = var.azure_monitor_private_link_scope_enabled ? 1 : 0

  location = var.location
  name = "pe-${var.azure_monitor_private_link_scope_name}-${var.location}"

  private_connection_resource_id = azurerm_monitor_private_link_scope.azure_monitor_private_link_scope[0].id
  subnet_resource_id = module.mgmt_virtual_network.subnets["snet-ampls"].resource_id
  resource_group_name = azurerm_resource_group.azure_monitor_private_link_scope[0].name
  network_interface_name = "nic-${var.azure_monitor_private_link_scope_name}-${var.location}"
  private_dns_zone_group_name = try(var.azure_monitor_private_link_scope_dns_zone_group_name, "default")
  private_dns_zone_resource_ids = var.azure_monitor_private_link_scope_dns_zone_resource_ids
  subresource_names = ["azuremonitor"]
}
