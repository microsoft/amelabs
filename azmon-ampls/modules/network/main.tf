# Network Module - VNet, Subnets, NSGs, and Peering

# Hub Virtual Network (where AMPLS will be deployed)
resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}-hub-vnet"
  address_space       = var.hub_vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Windows Spoke Virtual Network (where Windows VM will be deployed)
resource "azurerm_virtual_network" "windows_spoke" {
  name                = "${var.prefix}-windows-spoke-vnet"
  address_space       = var.windows_spoke_vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Ubuntu Spoke Virtual Network (where Ubuntu VM will be deployed)
resource "azurerm_virtual_network" "ubuntu_spoke" {
  name                = "${var.prefix}-ubuntu-spoke-vnet"
  address_space       = var.ubuntu_spoke_vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# App Service Spoke Virtual Network (where App Service integration will be deployed)
resource "azurerm_virtual_network" "appservice_spoke" {
  name                = "${var.prefix}-appservice-spoke-vnet"
  address_space       = var.appservice_spoke_vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Hub subnets
resource "azurerm_subnet" "hub_ampls" {
  name                 = "ampls-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.hub_ampls_subnet_address_prefixes

  private_endpoint_network_policies = "Disabled"

  depends_on = [
    azurerm_virtual_network.hub
  ]
}

# Spoke subnets
resource "azurerm_subnet" "windows_spoke_vms" {
  name                 = "vm-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.windows_spoke.name
  address_prefixes     = var.windows_spoke_vm_subnet_address_prefixes

  depends_on = [
    azurerm_virtual_network.windows_spoke
  ]
}

resource "azurerm_subnet" "ubuntu_spoke_vms" {
  name                 = "vm-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.ubuntu_spoke.name
  address_prefixes     = var.ubuntu_spoke_vm_subnet_address_prefixes

  depends_on = [
    azurerm_virtual_network.ubuntu_spoke
  ]
}

# App Service spoke subnet
resource "azurerm_subnet" "appservice_spoke_integration" {
  name                 = "appservice-integration-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.appservice_spoke.name
  address_prefixes     = var.appservice_spoke_integration_subnet_address_prefixes

  # Must be delegated for App Service integration
  delegation {
    name = "appservice-delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }

  depends_on = [
    azurerm_virtual_network.appservice_spoke
  ]
}

# VNet Peering Hub to Windows Spoke
resource "azurerm_virtual_network_peering" "hub_to_windows_spoke" {
  name                      = "hub-to-windows-spoke"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.windows_spoke.id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# VNet Peering Windows Spoke to Hub
resource "azurerm_virtual_network_peering" "windows_spoke_to_hub" {
  name                      = "windows-spoke-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.windows_spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# VNet Peering Hub to Ubuntu Spoke
resource "azurerm_virtual_network_peering" "hub_to_ubuntu_spoke" {
  name                      = "hub-to-ubuntu-spoke"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.ubuntu_spoke.id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# VNet Peering Ubuntu Spoke to Hub
resource "azurerm_virtual_network_peering" "ubuntu_spoke_to_hub" {
  name                      = "ubuntu-spoke-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.ubuntu_spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# VNet Peering Hub to App Service Spoke
resource "azurerm_virtual_network_peering" "hub_to_appservice_spoke" {
  name                      = "hub-to-appservice-spoke"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.appservice_spoke.id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# VNet Peering App Service Spoke to Hub
resource "azurerm_virtual_network_peering" "appservice_spoke_to_hub" {
  name                      = "appservice-spoke-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.appservice_spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Network Security Group for VMs
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.prefix}-vm-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow RDP for Windows VM
  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH for Ubuntu VM
  security_rule {
    name                       = "SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow outbound Azure Monitor traffic
  security_rule {
    name                       = "AzureMonitor"
    priority                   = 1003
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureMonitor"
  }

  tags = var.tags
}

# Associate NSG with Windows VM subnet
resource "azurerm_subnet_network_security_group_association" "windows_vm_subnet_nsg" {
  subnet_id                 = azurerm_subnet.windows_spoke_vms.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
  
  depends_on = [
    azurerm_subnet.windows_spoke_vms,
    azurerm_network_security_group.vm_nsg
  ]
}

# Associate NSG with Ubuntu VM subnet
resource "azurerm_subnet_network_security_group_association" "ubuntu_vm_subnet_nsg" {
  subnet_id                 = azurerm_subnet.ubuntu_spoke_vms.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
  
  depends_on = [
    azurerm_subnet.ubuntu_spoke_vms,
    azurerm_network_security_group.vm_nsg
  ]
}


