provider "azurerm" {
  client_id = "46c4a4f8-db09-4627-82cc-0bcbe3a5f0a0"
  client_secret = "4Fml_1ZN2fbe98x~R7PX1clF-BgwbaCJVc"
  tenant_id = "84f3059f-b882-43f8-9a82-d0e592cdde6b"
  subscription_id = "37418ca4-7beb-4f75-874d-e20981a8de17"
  features {}
}
resource "azurerm_resource_group" "rg" {
  name = var.resourcegroup_name
  location = "East US"
}

resource azurerm_virtual_network "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "subnet1" {
  name                 = var.subnet1_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "subnet2" {
  name                 = var.subnet2_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "subnet3" {
  name                 = var.subnet3_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_network_security_group" "testvmsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_public_ip" "testvmpublicip" {
  name                         = "testVMPublicIP"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  allocation_method            = "Dynamic"
	
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_network_interface" "testvmnic" {
    name                      = "testVMNic"
    location                  = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "testVMNicConfig"
        subnet_id                     = azurerm_subnet.subnet1.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.testvmpublicip.id
    }
  depends_on = [azurerm_public_ip.testvmpublicip]
}

resource "azurerm_network_interface_security_group_association" "nsgattach" {
    network_interface_id      = azurerm_network_interface.testvmnic.id
    network_security_group_id = azurerm_network_security_group.testvmsg.id
	depends_on = [azurerm_network_security_group.testvmsg]
}

resource "azurerm_linux_virtual_machine" "testvm" {
    name                  = var.vm_name
    location              = azurerm_resource_group.rg.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.testvmnic.id]
	admin_username = var.vm_username
	admin_password = var.vm_password
    disable_password_authentication = false
    size                  = "Standard_B2s"

    os_disk {
        name              = "testVMOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }
  depends_on = [azurerm_network_interface.testvmnic]
}

resource "azurerm_mysql_server" "mysql" {
  name                = var.mysql_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  administrator_login          = var.mysql_username
  administrator_login_password = var.mysql_password
  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"
  auto_grow_enabled                 = false
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_database" "mysql_db" {
  name                = var.mysql_dbname
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_firewall_rule" "mysql_firewall" {
  name                = "mysql_firewall_rule"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

#Creating a Jump Server in a  New Subnet
#Assigning a Public IP##
#Creating a Bastion host
resource "azurerm_subnet" "subnet4" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}
 
resource "azurerm_public_ip" "Public_IP" {
  name                = "BastionIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
 
resource "azurerm_bastion_host" "AzureBastion" {
  name                = "Bastion-New"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
 
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet4.id
    public_ip_address_id = azurerm_public_ip.Public_IP.id
  }
}

resource "azurerm_network_interface" "test1vmnic" {
    name                      = "test1VMNic"
    location                  = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "test1VMNicConfig"
        subnet_id                     = azurerm_subnet.subnet2.id
        private_ip_address_allocation = "Dynamic"
    }
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_network_interface_security_group_association" "nsgattach1" {
    network_interface_id      = azurerm_network_interface.test1vmnic.id
    network_security_group_id = azurerm_network_security_group.testvmsg.id
	depends_on = [azurerm_network_security_group.testvmsg]
}

resource "azurerm_linux_virtual_machine" "testvm1" {
    name                  = var.privatevm_name
    location              = azurerm_resource_group.rg.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.test1vmnic.id]
	admin_username = var.privatevm_username
	admin_password = var.privatevm_password
    disable_password_authentication = false
    size                  = "Standard_B2s"

    os_disk {
        name              = "test1VMOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }
  depends_on = [azurerm_network_interface.test1vmnic]
}