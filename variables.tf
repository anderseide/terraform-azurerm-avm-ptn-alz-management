variable "automation_account_name" {
  type        = string
  description = "The name of the Azure Automation Account to create."
}

variable "azure_monitor_private_link_scope_dns_zone_resource_ids" {
  type        = list(string)
  description = "(Required). The list of private DNS zone resource IDs for the Azure Monitor Private Link Scope."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be deployed."
  nullable    = false
}

variable "management_virtual_network_address_space" {
  type        = set(string)
  description = "(Optional). The address spaces applied to the virtual network. You can supply more than one address space."
  nullable    = false

  validation {
    condition     = length(var.management_virtual_network_address_space) > 0
    error_message = "Address space must contain at least one element."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Azure Resource Group where the resources will be created."
}

variable "automation_account_encryption" {
  type = object({
    key_vault_key_id          = string
    user_assigned_identity_id = optional(string, null)
  })
  default     = null
  description = "The encryption configuration for the Azure Automation Account."
}

variable "automation_account_identity" {
  type = object({
    type         = string
    identity_ids = optional(set(string), null)
  })
  default     = null
  description = "The identity to assign to the Azure Automation Account."
}

variable "automation_account_local_authentication_enabled" {
  type        = bool
  default     = true
  description = "Whether or not local authentication is enabled for the Azure Automation Account."
  nullable    = false
}

# Adding to support scenarios such as https://learn.microsoft.com/en-us/azure/automation/how-to/region-mappings#supported-mappings-for-log-analytics-and-azure-automation
variable "automation_account_location" {
  type        = string
  default     = null
  description = "The Azure region of the Azure Automation Account to deploy. This supports overriding the location variable in specific cases."
}

variable "automation_account_public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether or not public network access is enabled for the Azure Automation Account."
  nullable    = false
}

variable "automation_account_sku_name" {
  type        = string
  default     = "Basic"
  description = "The name of the SKU for the Azure Automation Account to create."
  nullable    = false
}

variable "azure_monitor_private_link_scope_dns_zone_group_name" {
  type        = string
  default     = null
  description = "(Optional). The name of the private DNS zone group for the Azure Monitor Private Link Scope."
}

variable "azure_monitor_private_link_scope_enabled" {
  type        = bool
  default     = false
  description = "A boolean flag to determine if Azure Monitor Private Link Scope should be enabled."
}

variable "azure_monitor_private_link_scope_ingestion_access_mode" {
  type        = string
  default     = "PrivateOnly"
  description = "The default ingestion access mode for the associated private endpoints in scope."

  validation {
    condition     = contains(["Open", "PrivateOnly"], var.azure_monitor_private_link_scope_ingestion_access_mode)
    error_message = "Possible values are Open and PrivateOnly."
  }
}

variable "azure_monitor_private_link_scope_name" {
  type        = string
  default     = null
  description = "The name of the Azure Monitor Private Link Scope that will be created."
}

variable "azure_monitor_private_link_scope_query_access_mode" {
  type        = string
  default     = "PrivateOnly"
  description = "The default query access mode for the associated private endpoints in scope."

  validation {
    condition     = contains(["Open", "PrivateOnly"], var.azure_monitor_private_link_scope_query_access_mode)
    error_message = "Possible values are Open and PrivateOnly."
  }
}

variable "azure_monitor_private_link_scope_resource_group_name" {
  type        = string
  default     = null
  description = "The name of the Azure Resource Group where Azure Monitor Private Link Scope will be created."
}

variable "data_collection_rules" {
  type = object({
    change_tracking = object({
      enabled  = optional(bool, true)
      name     = string
      location = optional(string, null)
      tags     = optional(map(string), null)
    })
    vm_insights = object({
      enabled  = optional(bool, true)
      name     = string
      location = optional(string, null)
      tags     = optional(map(string), null)
    })
    defender_sql = object({
      enabled                                                = optional(bool, true)
      name                                                   = string
      location                                               = optional(string, null)
      tags                                                   = optional(map(string), null)
      enable_collection_of_sql_queries_for_security_research = optional(bool, false)
    })
  })
  default = {
    change_tracking = {
      name = "dcr-change-tracking"
    }
    vm_insights = {
      name = "dcr-vm-insights"
    }
    defender_sql = {
      name = "dcr-defender-sql"
    }
  }
  description = <<DESCRIPTION
Enables customisation of the data collection rules for Azure Monitor.
This is an object with attributes pertaining to the three DCRs that are created by this module.

Each object has the following attributes:

- enabled (Optional) - Whether or not to create the data collection rule. Defaults to `true`.
- name (Required) - The name of the data collection rule. For the default values, see the default variable value.
- location (Optional) - The Azure region of the data collection rule. Defaults to the value of the location variable.
- tags (Optional) - A map of tags to apply to the data collection rule. Defaults to `null`.

The defender_sql object has an additional attribute:

- enable_collection_of_sql_queries_for_security_research (Optional) - Whether or not to enable collection of SQL queries for security research. Defaults to `false`.
DESCRIPTION
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "linked_automation_account_creation_enabled" {
  type        = bool
  default     = false
  description = "A boolean flag to determine whether to deploy the Azure Automation Account linked to the Log Analytics Workspace or not."
  nullable    = false
}

variable "log_analytics_solution_plans" {
  type = list(object({
    product   = string
    publisher = optional(string, "Microsoft")
  }))
  default = [
    {
      product   = "OMSGallery/ContainerInsights"
      publisher = "Microsoft"
    },
    {
      product   = "OMSGallery/VMInsights"
      publisher = "Microsoft"
    },
  ]
  description = <<DESCRIPTION
The Log Analytics Solution Plans to create.
Do not add the SecurityInsights solution plan here, this deployment method is deprecated. Instead refer to `sentinel_onboarding` variable.

The value of this variable is a list of objects with the following attributes:

- product (Required) - The product name of the solution plan, e.g. `OMSGallery/ContainerInsights`.
- publisher (Optional) - The publisher name of the solution plan, e.g. `Microsoft`. Defaults to `Microsoft`.
DESCRIPTION
  nullable    = false
}

variable "log_analytics_workspace_allow_resource_only_permissions" {
  type        = bool
  default     = true
  description = "Whether or not to allow resource-only permissions for the Log Analytics Workspace."
  nullable    = false
}

variable "log_analytics_workspace_cmk_for_query_forced" {
  type        = bool
  default     = null
  description = "Whether or not to force the use of customer-managed keys for query in the Log Analytics Workspace."
}

variable "log_analytics_workspace_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a Log Analytics Workspace."
}

variable "log_analytics_workspace_daily_quota_gb" {
  type        = number
  default     = null
  description = "The daily ingestion quota in GB for the Log Analytics Workspace."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The ID of the pre-existing Log Analytics Workspace to use. Required if `log_analytics_workspace_creation_enabled` is `false`."

  validation {
    condition = (
      var.log_analytics_workspace_creation_enabled == true ||
      (
        var.log_analytics_workspace_creation_enabled == false &&
        var.log_analytics_workspace_id != null &&
        can(regex("^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft.OperationalInsights/workspaces/[^/]+$", var.log_analytics_workspace_id))
      )
    )
    error_message = "You must supply a valid Log Analytics Workspace resource ID when log_analytics_workspace_creation_enabled is false.\nThe resource ID when specified must have the format '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/{workspaceName}'."
  }
}

variable "log_analytics_workspace_internet_ingestion_enabled" {
  type        = bool
  default     = true
  description = "Whether or not internet ingestion is enabled for the Log Analytics Workspace."
  nullable    = false
}

variable "log_analytics_workspace_internet_query_enabled" {
  type        = bool
  default     = true
  description = "Whether or not internet query is enabled for the Log Analytics Workspace."
  nullable    = false
}

variable "log_analytics_workspace_local_authentication_enabled" {
  type        = bool
  default     = true
  description = "Whether or not local authentication is enabled for the Log Analytics Workspace."
  nullable    = false
}

variable "log_analytics_workspace_name" {
  type        = string
  default     = null
  description = "The name of the Log Analytics Workspace to create."

  validation {
    condition = (
      var.log_analytics_workspace_creation_enabled == false ||
      (var.log_analytics_workspace_creation_enabled == true && var.log_analytics_workspace_name != null)
    )
    error_message = "You must supply a value for log_analytics_workspace_name when log_analytics_workspace_creation_enabled is true."
  }
}

variable "log_analytics_workspace_reservation_capacity_in_gb_per_day" {
  type        = number
  default     = null
  description = "The reservation capacity in GB per day for the Log Analytics Workspace."
}

variable "log_analytics_workspace_retention_in_days" {
  type        = number
  default     = 30
  description = "The number of days to retain data for the Log Analytics Workspace."
  nullable    = false
}

variable "log_analytics_workspace_sku" {
  type        = string
  default     = "PerGB2018"
  description = "The SKU to use for the Log Analytics Workspace."
  nullable    = false
}

variable "management_virtual_network_enabled" {
  type        = bool
  default     = false
  description = "(Optional). A boolean flag to determine if Management subscription should have virtual network deployed."
}

variable "management_virtual_network_name" {
  type        = string
  default     = null
  description = "(Optional). Name of the virtual network in management subscription."
}

variable "management_virtual_network_peerings" {
  type = map(object({
    name                               = string
    remote_virtual_network_resource_id = string
    allow_forwarded_traffic            = optional(bool, false)
    allow_gateway_transit              = optional(bool, false)
    allow_virtual_network_access       = optional(bool, true)
    do_not_verify_remote_gateways      = optional(bool, false)
    enable_only_ipv6_peering           = optional(bool, false)
    peer_complete_vnets                = optional(bool, true)
    local_peered_address_spaces = optional(list(object({
      address_prefix = string
    })))
    remote_peered_address_spaces = optional(list(object({
      address_prefix = string
    })))
    local_peered_subnets = optional(list(object({
      subnet_name = string
    })))
    remote_peered_subnets = optional(list(object({
      subnet_name = string
    })))
    use_remote_gateways                   = optional(bool, false)
    create_reverse_peering                = optional(bool, false)
    reverse_name                          = optional(string)
    reverse_allow_forwarded_traffic       = optional(bool, false)
    reverse_allow_gateway_transit         = optional(bool, false)
    reverse_allow_virtual_network_access  = optional(bool, true)
    reverse_do_not_verify_remote_gateways = optional(bool, false)
    reverse_enable_only_ipv6_peering      = optional(bool, false)
    reverse_peer_complete_vnets           = optional(bool, true)
    reverse_local_peered_address_spaces = optional(list(object({
      address_prefix = string
    })))
    reverse_remote_peered_address_spaces = optional(list(object({
      address_prefix = string
    })))
    reverse_local_peered_subnets = optional(list(object({
      subnet_name = string
    })))
    reverse_remote_peered_subnets = optional(list(object({
      subnet_name = string
    })))
    reverse_use_remote_gateways = optional(bool, false)
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }), {})
    retry = optional(object({
      error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned"])
      interval_seconds     = optional(number, 10)
      max_interval_seconds = optional(number, 180)
      multiplier           = optional(number, 1.5)
      randomization_factor = optional(number, 0.5)
    }), {})
  }))
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of virtual network peering configurations. Each entry specifies a remote virtual network by ID and includes settings for traffic forwarding, gateway transit, and remote gateways usage.

- `name`: The name of the virtual network peering configuration.
- `remote_virtual_network_resource_id`: The resource ID of the remote virtual network.
- `allow_forwarded_traffic`: (Optional) Enables forwarded traffic between the virtual networks. Defaults to false.
- `allow_gateway_transit`: (Optional) Enables gateway transit for the virtual networks. Defaults to false.
- `allow_virtual_network_access`: (Optional) Enables access from the local virtual network to the remote virtual network. Defaults to true.
- `do_not_verify_remote_gateways`: (Optional) Disables the verification of remote gateways for the virtual networks. Defaults to false.
- `enable_only_ipv6_peering`: (Optional) Enables only IPv6 peering for the virtual networks. Defaults to false.
- `peer_complete_vnets`: (Optional) Enables the peering of complete virtual networks for the virtual networks. Defaults to false.
- `local_peered_address_spaces`: (Optional) The address spaces to peer with the remote virtual network. Only used when `peer_complete_vnets` is set to true.
- `remote_peered_address_spaces`: (Optional) The address spaces to peer from the remote virtual network. Only used when `peer_complete_vnets` is set to true.
- `local_peered_subnets`: (Optional) The subnets to peer with the remote virtual network. Only used when `peer_complete_vnets` is set to true.
- `remote_peered_subnets`: (Optional) The subnets to peer from the remote virtual network. Only used when `peer_complete_vnets` is set to true.
- `use_remote_gateways`: (Optional) Enables the use of remote gateways for the virtual networks. Defaults to false.
- `create_reverse_peering`: (Optional) Creates the reverse peering to form a complete peering.
- `reverse_name`: (Optional) If you have selected `create_reverse_peering`, then this name will be used for the reverse peer.
- `reverse_allow_forwarded_traffic`: (Optional) If you have selected `create_reverse_peering`, enables forwarded traffic between the virtual networks. Defaults to false.
- `reverse_allow_gateway_transit`: (Optional) If you have selected `create_reverse_peering`, enables gateway transit for the virtual networks. Defaults to false.
- `reverse_allow_virtual_network_access`: (Optional) If you have selected `create_reverse_peering`, enables access from the local virtual network to the remote virtual network. Defaults to true.
- `reverse_do_not_verify_remote_gateways`: (Optional) If you have selected `create_reverse_peering`, disables the verification of remote gateways for the virtual networks. Defaults to false.
- `reverse_enable_only_ipv6_peering`: (Optional) If you have selected `create_reverse_peering`, enables only IPv6 peering for the virtual networks. Defaults to false.
- `reverse_peer_complete_vnets`: (Optional) If you have selected `create_reverse_peering`, enables the peering of complete virtual networks for the virtual networks. Defaults to false.
- `reverse_local_peered_address_spaces`: (Optional) If you have selected `create_reverse_peering`, the address spaces to peer with the remote virtual network. Only used when `reverse_peer_complete_vnets` is set to true.
- `reverse_remote_peered_address_spaces`: (Optional) If you have selected `create_reverse_peering`, the address spaces to peer from the remote virtual network. Only used when `reverse_peer_complete_vnets` is set to true.
- `reverse_local_peered_subnets`: (Optional) If you have selected `create_reverse_peering`, the subnets to peer with the remote virtual network. Only used when `reverse_peer_complete_vnets` is set to true.
- `reverse_remote_peered_subnets`: (Optional) If you have selected `create_reverse_peering`, the subnets to peer from the remote virtual network. Only used when `reverse_peer_complete_vnets` is set to true.
- `reverse_use_remote_gateways`: (Optional) If you have selected `create_reverse_peering`, enables the use of remote gateways for the virtual networks. Defaults to false.

 ---
 `timeouts` (Optional) supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Subnet.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Subnet.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Subnet.
 - `update` - (Defaults to 30 minutes) Used when updating the Subnet.

---
  `retry` (Optional) supports the following:
  - `error_message_regex` - (Optional) A list of regular expressions to match against the error message returned by the API. If any of these match, the retry will be triggered.
  - `interval_seconds` - (Optional) The number of seconds to wait between retries. Defaults to 10.
  - `max_interval_seconds` - (Optional) The maximum number of seconds to wait between retries. Defaults to 180.
  - `multiplier` - (Optional) The multiplier to apply to the interval between retries Defaults to 1.5.
  - `randomization_factor` - (Optional) The randomization factor to apply to the interval between retries. Defaults to 0.5.

DESCRIPTION
  nullable    = false
}

variable "management_virtual_network_resource_group_name" {
  type        = string
  default     = null
  description = "(Optional). Name of the resource group holding the virtual network in management subscription."
}

variable "management_virtual_network_subnets" {
  type = map(object({
    address_prefix   = optional(string)
    address_prefixes = optional(list(string))
    name             = string
    nat_gateway = optional(object({
      id = string
    }))
    network_security_group = optional(object({
      id = string
    }))
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    route_table = optional(object({
      id = string
    }))
    service_endpoint_policies = optional(map(object({
      id = string
    })))
    service_endpoints               = optional(set(string))
    default_outbound_access_enabled = optional(bool, false)
    sharing_scope                   = optional(string, null)
    delegation = optional(list(object({
      name = string
      service_delegation = object({
        name = string
      })
    })))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }), {})
    retry = optional(object({
      error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned"])
      interval_seconds     = optional(number, 10)
      max_interval_seconds = optional(number, 180)
      multiplier           = optional(number, 1.5)
      randomization_factor = optional(number, 0.5)
    }), {})
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })))
  }))
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of subnets to create

 - `address_prefix` - (Optional) The address prefix to use for the subnet. One of `address_prefix` or `address_prefixes` must be specified.
 - `address_prefixes` - (Optional) The address prefixes to use for the subnet. One of `address_prefix` or `address_prefixes` must be specified.
 - `enforce_private_link_endpoint_network_policies` -
 - `enforce_private_link_service_network_policies` -
 - `name` - (Required) The name of the subnet. Changing this forces a new resource to be created.
 - `default_outbound_access_enabled` - (Optional) Whether to allow internet access from the subnet. Defaults to `false`.
 - `private_endpoint_network_policies` - (Optional) Enable or Disable network policies for the private endpoint on the subnet. Possible values are `Disabled`, `Enabled`, `NetworkSecurityGroupEnabled` and `RouteTableEnabled`. Defaults to `Enabled`.
 - `private_link_service_network_policies_enabled` - (Optional) Enable or Disable network policies for the private link service on the subnet. Setting this to `true` will **Enable** the policy and setting this to `false` will **Disable** the policy. Defaults to `true`.
 - `service_endpoint_policies` - (Optional) The map of objects with IDs of Service Endpoint Policies to associate with the subnet.
 - `service_endpoints` - (Optional) The list of Service endpoints to associate with the subnet. Possible values include: `Microsoft.AzureActiveDirectory`, `Microsoft.AzureCosmosDB`, `Microsoft.ContainerRegistry`, `Microsoft.EventHub`, `Microsoft.KeyVault`, `Microsoft.ServiceBus`, `Microsoft.Sql`, `Microsoft.Storage`, `Microsoft.Storage.Global` and `Microsoft.Web`.

 ---
 `delegation` supports the following:
 - `name` - (Required) A name for this delegation.

 ---
 `nat_gateway` supports the following:
 - `id` - (Optional) The ID of the NAT Gateway which should be associated with the Subnet. Changing this forces a new resource to be created.

 ---
 `network_security_group` supports the following:
 - `id` - (Optional) The ID of the Network Security Group which should be associated with the Subnet. Changing this forces a new association to be created.

 ---
 `route_table` supports the following:
 - `id` - (Optional) The ID of the Route Table which should be associated with the Subnet. Changing this forces a new association to be created.

 ---
 `timeouts` (Optional) supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Subnet.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Subnet.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Subnet.
 - `update` - (Defaults to 30 minutes) Used when updating the Subnet.

---
  `retry` (optional) supports the following:
  - `error_message_regex` - (Optional) A list of regular expressions to match against the error message returned by the API. If any of these match, the retry will be triggered.
  - `interval_seconds` - (Optional) The number of seconds to wait between retries. Defaults to 10.
  - `max_interval_seconds` - (Optional) The maximum number of seconds to wait between retries. Defaults to 180.
  - `multiplier` - (Optional) The multiplier to apply to the interval between retries Defaults to 1.5.
  - `randomization_factor` - (Optional) The randomization factor to apply to the interval between retries. Defaults to 0.5.

 ---
 `role_assignments` supports the following:
 - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
 - `principal_id` - The ID of the principal to assign the role to.
 - `description` - (Optional) The description of the role assignment.
 - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
 - `condition` - (Optional) The condition which will be used to scope the role assignment.
 - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
 - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
 - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

DESCRIPTION

  validation {
    condition     = alltrue([for _, subnet in var.management_virtual_network_subnets : subnet.address_prefix != null || subnet.address_prefixes != null])
    error_message = "One of `address_prefix` or `address_prefixes` must be set."
  }
}

variable "resource_group_creation_enabled" {
  type        = bool
  default     = true
  description = "A boolean flag to determine whether to deploy the Azure Resource Group or not."
  nullable    = false
}

variable "sentinel_onboarding" {
  type = object({
    name                         = optional(string, "default")
    customer_managed_key_enabled = optional(bool, false)
  })
  default     = {}
  description = <<DESCRIPTION
Enables customisation of the Sentinel onboarding. Set to `null` to disable.

This is an object with the following attributes:

- name (Optional) - The name of the Sentinel onboarding object. Defaults to `default`.
- customer_managed_key_enabled (Optional) - Whether or not to enable customer-managed keys for the Sentinel onboarding. Defaults to `false`.
DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "A map of tags to apply to the resources created."
}

variable "timeouts" {
  type = object({
    sentinel_onboarding = optional(object({
      create = optional(string, "5m")
      delete = optional(string, "5m")
      update = optional(string, "5m")
      read   = optional(string, "5m")
      }), {}
    )
    data_collection_rule = optional(object({
      create = optional(string, "5m")
      delete = optional(string, "10m")
      update = optional(string, "5m")
      read   = optional(string, "5m")
      }), {}
    )
  })
  default     = {}
  description = <<DESCRIPTION
A map of timeouts to apply to the creation and destruction of resources.
If using retry, the maximum elapsed retry time is governed by this value.

The object has attributes for each resource type, with the following optional attributes:

- `create` - (Optional) The timeout for creating the resource. Defaults to `5m`.
- `delete` - (Optional) The timeout for deleting the resource. Defaults to `5m` apart from data_collection_rule, where this is set to `10m`.
- `update` - (Optional) The timeout for updating the resource. Defaults to `5m`.
- `read` - (Optional) The timeout for reading the resource. Defaults to `5m`.

Each time duration is parsed using this function: <https://pkg.go.dev/time#ParseDuration>.
DESCRIPTION
}

variable "user_assigned_managed_identities" {
  type = object({
    ama = object({
      enabled  = optional(bool, true)
      name     = string
      location = optional(string, null)
      tags     = optional(map(string), null)
    })
  })
  default = {
    ama = {
      name = "uami-ama"
    }
  }
  description = <<DESCRIPTION
Enables customisation of the user assigned managed identities.

The value of this variable is an object with the following attributes:

- ama (Required) - The user assigned managed identity for the Azure Monitor Agent.
  - enabled (Optional) - Whether or not to create the user assigned managed identity. Defaults to `true`.
  - name (Required) - The name of the user assigned managed identity, the variable default value is `uami-ama`.
  - location (Optional) - The Azure region of the user assigned managed identity. Defaults to the value of the location variable.
  - tags (Optional) - A map of tags to apply to the user assigned managed identity. Defaults to `null`.
DESCRIPTION
}
