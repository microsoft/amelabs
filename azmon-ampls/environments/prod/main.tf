# Azure Monitor AMPLS Lab - Production Environment
# This configuration creates a lab environment to demonstrate
# Azure Monitor private connectivity using AMPLS with a modular structure

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Network Module
module "network" {
  source = "../../modules/network"

  prefix              = "azmon"  # Fixed prefix for infrastructure
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  hub_vnet_address_space               = var.hub_vnet_address_space
  windows_spoke_vnet_address_space     = var.windows_spoke_vnet_address_space
  ubuntu_spoke_vnet_address_space      = var.ubuntu_spoke_vnet_address_space
  appservice_spoke_vnet_address_space  = var.appservice_spoke_vnet_address_space
  
  hub_ampls_subnet_address_prefixes    = var.hub_ampls_subnet_address_prefixes
  windows_spoke_vm_subnet_address_prefixes = var.windows_spoke_vm_subnet_address_prefixes
  ubuntu_spoke_vm_subnet_address_prefixes  = var.ubuntu_spoke_vm_subnet_address_prefixes
  appservice_spoke_integration_subnet_address_prefixes = var.appservice_spoke_integration_subnet_address_prefixes

  tags = var.tags
}

# Monitor Module
module "monitor" {
  source = "../../modules/monitor"

  prefix                        = "azmon"  # Fixed prefix for infrastructure
  location                      = var.location
  resource_group_name           = azurerm_resource_group.main.name
  log_analytics_workspace_name  = var.log_analytics_workspace_name

  ampls_subnet_id = module.network.hub_ampls_subnet_id
  hub_vnet_id     = module.network.hub_vnet_id
  windows_spoke_vnet_id = module.network.windows_spoke_vnet_id
  ubuntu_spoke_vnet_id  = module.network.ubuntu_spoke_vnet_id
  appservice_spoke_vnet_id = module.network.appservice_spoke_vnet_id

  log_analytics_sku             = var.log_analytics_sku
  log_analytics_retention_days  = var.log_analytics_retention_days
  perf_counter_sampling_frequency = var.perf_counter_sampling_frequency

  depends_on = [
    module.network
  ]

  tags = var.tags
}

# Compute Module
module "compute" {
  source = "../../modules/compute"

  prefix              = "azmon"  # Fixed prefix for infrastructure
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  windows_vm_subnet_id    = module.network.windows_spoke_vm_subnet_id
  ubuntu_vm_subnet_id     = module.network.ubuntu_spoke_vm_subnet_id
  data_collection_rule_id = module.monitor.data_collection_rule_id
  ubuntu_data_collection_rule_id = module.monitor.ubuntu_data_collection_rule_id
  data_collection_endpoint_id = module.monitor.data_collection_endpoint_id

  # Application Insights configuration
  application_insights_connection_string = module.monitor.connection_string

  admin_username    = var.admin_username
  admin_password    = var.admin_password
  vm_size           = var.vm_size
  enable_public_ips = var.enable_public_ips

  # Auto-shutdown configuration
  enable_autoshutdown                    = var.enable_autoshutdown
  autoshutdown_time                     = var.autoshutdown_time
  autoshutdown_timezone                 = var.autoshutdown_timezone
  autoshutdown_notification_enabled     = var.autoshutdown_notification_enabled
  autoshutdown_notification_email       = var.autoshutdown_notification_email

  depends_on = [
    module.network,
    module.monitor
  ]

  tags = var.tags
}

#App Service Module
module "appservice" {
 source = "../../modules/appservice"

  prefix              = var.app_service_prefix  # Custom prefix for App Services only
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  plan_sku            = "B2"  # Basic B2: 2 cores, 3.5GB RAM, dev/test pricing
  integration_subnet_id = module.network.appservice_integration_subnet_id

  log_analytics_workspace_id    = module.monitor.log_analytics_workspace_id
  appinsights_connection_string = module.monitor.connection_string

  tags = var.tags
}

