terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}


module "resource_group" {
  source              = "./modules/resource_group"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "log_analytics" {
  source              = "./modules/log_analytics"
  resource_group_name = module.resource_group.name
  location            = var.location
  workspace_name      = var.workspace_name
}

module "network" {
  source              = "./modules/network"
  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_name         = "vmss_subnet"
}


module "vmss_windows" {
  source              = "./modules/vmss_windows"
  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.network.subnet_id
  backend_pool_id     = module.network.backend_pool_id
  workspace_id        = module.log_analytics.workspace_id
  vmss_name           = var.vmss_name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
}


module "dcr_vmss" {
  source              = "./modules/dcr_vmss"
  resource_group_name = module.resource_group.name
  location            = var.location
  workspace_id        = module.log_analytics.workspace_id
  target_resource_id  = module.vmss_windows.vmss_id
  
  depends_on = [module.vmss_windows]
}

# Network Interface for Ubuntu VM
resource "azurerm_public_ip" "ubuntu_vm_public_ip" {
  name                = "${var.ubuntu_vm_name}-public-ip"
  location            = var.location
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = "Lab"
    Purpose     = "Ubuntu VM"
  }
}

resource "azurerm_network_interface" "ubuntu_vm_nic" {
  name                = "${var.ubuntu_vm_name}-nic"
  location            = var.location
  resource_group_name = module.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ubuntu_vm_public_ip.id
  }

  tags = {
    Environment = "Lab"
    Purpose     = "Ubuntu VM"
  }
}

# Network Security Group for Ubuntu VM (SSH access)
resource "azurerm_network_security_group" "ubuntu_vm_nsg" {
  name                = "${var.ubuntu_vm_name}-nsg"
  location            = var.location
  resource_group_name = module.resource_group.name

  security_rule {
    name                       = "allow_http"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_https"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Lab"
    Purpose     = "Ubuntu VM"
  }
}

resource "azurerm_network_interface_security_group_association" "ubuntu_vm_nsg_association" {
  network_interface_id      = azurerm_network_interface.ubuntu_vm_nic.id
  network_security_group_id = azurerm_network_security_group.ubuntu_vm_nsg.id
}

# Ubuntu VM Module
module "vm_ubuntu" {
  source              = "./modules/vm_ubuntu"
  vm_name             = var.ubuntu_vm_name
  resource_group_name = module.resource_group.name
  location            = var.location
  vm_size             = var.ubuntu_vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  nic_id              = azurerm_network_interface.ubuntu_vm_nic.id
  workspace_id        = module.log_analytics.workspace_id

  tags = {
    Environment = "Lab"
    Purpose     = "Ubuntu VM"
    Project     = "Azure Monitoring"
  }
}



# Network Interface for Windows VM
resource "azurerm_public_ip" "windows_vm_public_ip" {
  name                = "${var.windows_vm_name}-public-ip"
  location            = var.location
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = "Lab"
    Purpose     = "Windows VM"
  }
}

resource "azurerm_network_interface" "windows_vm_nic" {
  name                = "${var.windows_vm_name}-nic"
  location            = var.location
  resource_group_name = module.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows_vm_public_ip.id
  }

  tags = {
    Environment = "Lab"
    Purpose     = "Windows VM"
  }
}

# Network Security Group for Windows VM (RDP access)
resource "azurerm_network_security_group" "windows_vm_nsg" {
  name                = "${var.windows_vm_name}-nsg"
  location            = var.location
  resource_group_name = module.resource_group.name

  security_rule {
    name                       = "allow_http"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_https"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Lab"
    Purpose     = "Windows VM"
  }
}

resource "azurerm_network_interface_security_group_association" "windows_vm_nsg_association" {
  network_interface_id      = azurerm_network_interface.windows_vm_nic.id
  network_security_group_id = azurerm_network_security_group.windows_vm_nsg.id
}

# Windows VM Module
module "vm_windows" {
  source              = "./modules/vm_windows"
  vm_name             = var.windows_vm_name
  resource_group_name = module.resource_group.name
  location            = var.location
  vm_size             = var.windows_vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  nic_id              = azurerm_network_interface.windows_vm_nic.id

  tags = {
    Environment = "Lab"
    Purpose     = "Windows VM"
    Project     = "Azure Monitoring"
  }
}


# Network Interface for Red Hat VM
resource "azurerm_public_ip" "redhat_vm_public_ip" {
  name                = "${var.redhat_vm_name}-public-ip"
  location            = var.location
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = "Lab"
    Purpose     = "Red Hat VM"
  }
}

resource "azurerm_network_interface" "redhat_vm_nic" {
  name                = "${var.redhat_vm_name}-nic"
  location            = var.location
  resource_group_name = module.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.redhat_vm_public_ip.id
  }

  tags = {
    Environment = "Lab"
    Purpose     = "Red Hat VM"
  }
}

# Network Security Group for Red Hat VM (SSH access)
resource "azurerm_network_security_group" "redhat_vm_nsg" {
  name                = "${var.redhat_vm_name}-nsg"
  location            = var.location
  resource_group_name = module.resource_group.name
 
  security_rule {
    name                       = "allow_http"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_https"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_syslog"
    priority                   = 1300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "514"
    source_address_prefixes    = ["10.0.2.0/24"]  # Internal subnet only
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_cef_tcp"
    priority                   = 1400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "514"
    source_address_prefixes    = ["10.0.2.0/24"]  # Internal subnet only
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Lab"
    Purpose     = "Red Hat VM"
  }
}

resource "azurerm_network_interface_security_group_association" "redhat_vm_nsg_association" {
  network_interface_id      = azurerm_network_interface.redhat_vm_nic.id
  network_security_group_id = azurerm_network_security_group.redhat_vm_nsg.id
}

# Red Hat VM Module
module "vm_redhat" {
  source              = "./modules/vm_redhat"
  vm_name             = var.redhat_vm_name
  resource_group_name = module.resource_group.name
  location            = var.location
  vm_size             = var.redhat_vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  nic_id              = azurerm_network_interface.redhat_vm_nic.id
  workspace_id        = module.log_analytics.workspace_id

  tags = {
    Environment = "Lab"
    Purpose     = "Red Hat VM"
    Project     = "Azure Monitoring"
  }
}

# Microsoft Sentinel Configuration
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "main" {
  workspace_id = module.log_analytics.workspace_id
}

# CEF Data Collection Rule
resource "azurerm_monitor_data_collection_rule" "cef_dcr" {
  name                = "dcr-cef-sentinel"
  location            = var.location
  resource_group_name = module.resource_group.name
  kind                = "Linux"

  data_sources {
    syslog {
      name           = "syslog-cef"
      streams        = ["Microsoft-CommonSecurityLog"]
      facility_names = ["user", "mail", "daemon", "auth", "syslog", "lpr", "news", "uucp", "ftp", "ntp", "audit", "alert", "mark", "local0", "local1", "local2", "local3", "local4", "local5", "local6", "local7"]
      log_levels     = ["Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
    }
  }

  destinations {
    log_analytics {
      name                  = "sentinel-destination"
      workspace_resource_id = module.log_analytics.workspace_id
    }
  }

  data_flow {
    streams      = ["Microsoft-CommonSecurityLog"]
    destinations = ["sentinel-destination"]
  }

  tags = {
    Environment = "Lab"
    Purpose     = "CEF Data Collection"
    Project     = "Azure Monitoring"
  }

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.main,
    module.log_analytics,
    module.vm_redhat
  ]
}

# Associate CEF DCR with Red Hat VM
resource "azurerm_monitor_data_collection_rule_association" "cef_dcr_redhat_association" {
  name                    = "cef-dcr-redhat-association"
  data_collection_rule_id = azurerm_monitor_data_collection_rule.cef_dcr.id
  target_resource_id      = module.vm_redhat.vm_id
}

# Syslog Data Collection Rule for Ubuntu VM
resource "azurerm_monitor_data_collection_rule" "syslog_dcr" {
  name                = "dcr-syslog-ubuntu"
  location            = var.location
  resource_group_name = module.resource_group.name
  kind                = "Linux"

  data_sources {
    syslog {
      name           = "syslog-all"
      streams        = ["Microsoft-Syslog"]
      facility_names = ["user", "mail", "daemon", "auth", "syslog", "lpr", "news", "uucp", "ftp", "ntp", "audit", "alert", "mark", "local0", "local1", "local2", "local3", "local4", "local5", "local6", "local7"]
      log_levels     = ["Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
    }
  }

  destinations {
    log_analytics {
      name                  = "log-analytics-destination"
      workspace_resource_id = module.log_analytics.workspace_id
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["log-analytics-destination"]
  }

  tags = {
    Environment = "Lab"
    Purpose     = "Ubuntu Syslog Collection"
    Project     = "Azure Monitoring"
  }

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.main,
    module.log_analytics,
    module.vm_ubuntu
  ]
}

# Associate Syslog DCR with Ubuntu VM
resource "azurerm_monitor_data_collection_rule_association" "syslog_dcr_ubuntu_association" {
  name                    = "syslog-dcr-ubuntu-association"
  data_collection_rule_id = azurerm_monitor_data_collection_rule.syslog_dcr.id
  target_resource_id      = module.vm_ubuntu.vm_id
}

module "automation_runbook" {
  source                  = "./modules/automation_runbook"
  resource_group_name     = module.resource_group.name
  location                = var.location
  automation_account_name = var.automation_account_name
  vmss_name               = var.vmss_name
  user_timezone_hour      = length(var.user_timezone) == 4 ? "${substr(var.user_timezone, 0, 2)}:${substr(var.user_timezone, 2, 2)}" : "19:00"
  subscription_id         = var.subscription_id
  aks_name                = var.aks_name

  depends_on = [module.vmss_windows]
}

# VM Insights Module - Enable VM Insights with Dependency Agent for all VMs
module "vm_insights" {
  source = "./modules/vm_insights"

  resource_group_name = module.resource_group.name
  location           = var.location
  workspace_name     = var.workspace_name
  workspace_id       = module.log_analytics.workspace_id
  subscription_id    = var.subscription_id

  # Windows VM configuration
  windows_vm_id   = module.vm_windows.vm_id
  windows_vm_name = var.windows_vm_name

  # RedHat VM configuration
  redhat_vm_id   = module.vm_redhat.vm_id
  redhat_vm_name = var.redhat_vm_name

  # Ubuntu VM configuration
  ubuntu_vm_id   = module.vm_ubuntu.vm_id
  ubuntu_vm_name = var.ubuntu_vm_name

  tags = {
    Environment = "Lab"
    Purpose     = "VM Insights Monitoring"
    Project     = "Azure Monitoring"
  }

  depends_on = [
    module.log_analytics,
    module.vm_windows,
    module.vm_redhat,
    module.vm_ubuntu
  ]
}

