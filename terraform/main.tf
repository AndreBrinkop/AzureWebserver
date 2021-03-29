provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.project}-resources"
  location = var.location

  tags = {
    project = var.project
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.project}-network"
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    project = var.project
  }
}

resource "azurerm_subnet" "main" {
  name                 = "${var.project}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.project}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    project = var.project
  }
}

resource "azurerm_network_security_rule" "internal" {
  name                        = "allow-internal"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "http-traffic" {
  name                        = "allow-http-traffic"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "external" {
  name                        = "deny-internet"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "${var.project}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal-ip-configuration-${count.index}"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    project = var.project
  }
}

resource "azurerm_public_ip" "main" {
  name                = "${var.project}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    project = var.project
  }
}

resource "azurerm_lb" "main" {
  name                = "${var.project}-load-balancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "public-ip-address"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    project = var.project
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  name                = "${var.project}-backend-address-pool"
  loadbalancer_id     = azurerm_lb.main.id
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count = var.vm_count

  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "internal-ip-configuration-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_availability_set" "main" {
  name                = "${var.project}-availability-set"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  platform_fault_domain_count = var.fault_domain_count

  tags = {
    project = var.project
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vm_count

  name                            = "${var.project}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  availability_set_id             = azurerm_availability_set.main.id
  size                            = "Standard_B1ls"

  admin_username                  = var.vm_username
  admin_password                  = var.vm_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  source_image_id = var.image_id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    project = var.project
  }
}