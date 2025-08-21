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
