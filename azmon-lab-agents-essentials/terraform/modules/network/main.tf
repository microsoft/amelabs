resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-lab"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_public_ip" "lb_public_ip" {
  name                = "lb-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_lb" "lb" {
  name                = "lb-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bap" {
  name            = "backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "rdp_probe" {
  name                = "rdp-health-probe"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Tcp"
  port                = 3389
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "rdp_rule" {
  name                           = "rdp-load-balancing-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bap.id]
  probe_id                       = azurerm_lb_probe.rdp_probe.id
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow_rdp"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"  # Allow RDP from any source to load balancer
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Lab"
    Purpose     = "VMSS Load Balancer Security"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}