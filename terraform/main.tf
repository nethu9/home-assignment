data "azurerm_resource_group" "temperature_rg" {
  name = "${var.app}-rg"
}

resource "azurerm_virtual_network" "temperature_vn" {
  name = "${var.app}-vn"
  resource_group_name = data.azurerm_resource_group.temperature_rg.name
  address_space = var.address_space
  location = var.location
}

resource "azurerm_subnet" "public_subnet" {
  name = "${var.app}-public-subnet"
  virtual_network_name = azurerm_virtual_network.temperature_vn.name
  resource_group_name = data.azurerm_resource_group.temperature_rg.name
  address_prefixes = [ "10.0.1.0/24" ]
}

resource "azurerm_network_security_group" "temperature_nsg" {
  name = "${var.app}-nsg"
  resource_group_name = data.azurerm_resource_group.temperature_rg.name
  location = var.location

  security_rule {
    name = "AllowSSH"
    priority = 100
    direction = "Inbound"
    access = "Allow"   
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule  {
    name = "Prometheus"
    priority  = 105
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "9090"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule  {
    name = "Grafana"
    priority  = 110
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3000"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "TemperatureApp"
    priority = 115
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "8000"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_sg_association" {
  subnet_id = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.temperature_nsg.id
}

resource "azurerm_public_ip" "public_ip" {
  name = "${var.app}-pip"
  allocation_method = "Static"
  resource_group_name = data.azurerm_resource_group.temperature_rg.name
  location = var.location
  sku = "Standard"
}

resource "azurerm_network_interface" "network_interface" {
  name = "${var.app}-network-interface"
  resource_group_name = data.azurerm_resource_group.temperature_rg.name
  location = var.location
  ip_configuration {
    name = "ipconfig"
    subnet_id = azurerm_subnet.public_subnet.id
    public_ip_address_id = azurerm_public_ip.public_ip.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name = "${var.vm_name}-vm"
  resource_group_name = data.azurerm_resource_group.temperature_rg.name
  size = var.size
  location = var.location
  admin_username = var.admin_username
  network_interface_ids = [ azurerm_network_interface.network_interface.id ]
  admin_ssh_key {
    username = var.admin_username
    public_key = var.ssh_public_key
  }
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
    custom_data = base64encode(templatefile("cloud-init.yml", {
    weather_api_key = var.weather_api_key
  }))
  
}
