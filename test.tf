provider "azurerm" {}

resource "azurerm_resource_group" "myterraformgroup" {
  name     = "azureTF-rg"
  location = "westus"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "${azurerm_resource_group.myterraformgroup.name}-net"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.myterraformgroup.location}"
  resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "${azurerm_resource_group.myterraformgroup.name}-subnet"
  resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
  virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "myterraformpublicip" {
  name                         = "${azurerm_virtual_network.myterraformnetwork.name}-publicIP"
  location                     = "${azurerm_resource_group.myterraformgroup.location}"
  resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "tfvm2018jj"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_security_group" "temyterraformpublicipnsg" {
  name                = "${azurerm_virtual_network.myterraformnetwork.name}-networkSecurityGroup"
  location            = "${azurerm_resource_group.myterraformgroup.location}"
  resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_interface" "myterraformnic" {
  name                = "${azurerm_virtual_network.myterraformnetwork.name}-myNIC"
  location            = "${azurerm_resource_group.myterraformgroup.location}"
  resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
  }

  tags {
    environment = "Terraform Demo"
  }
}

resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.myterraformgroup.name}"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = "${azurerm_resource_group.myterraformgroup.name}"
  location                 = "${azurerm_resource_group.myterraformgroup.location}"
  account_replication_type = "LRS"
  account_tier             = "Standard_A3"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_virtual_machine" "myterraformvm" {
  name                  = "${azurerm_resource_group.myterraformgroup.name}-vm"
  location              = "${azurerm_resource_group.myterraformgroup.location}"
  resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
  network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${azurerm_resource_group.myterraformgroup.name}-vm"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwyhN7++iT/2E3/D+AcCEUjN+aZEDnPmnL+nhROEfXdx9b2OVYekwO48k4/AbNQm5S6ueceExwJXTSe//KpUfX5zd8bx82LcCb36Rm9KpGuy0tyh5cMWU9swxEP0KDd0lySrtvHJF0tuK/CWUl3FOH8HIDqMWR+Ks5dD1EEymv8kfGa1NXoXQZS1xKiqMQP7hCsmVQeJvoLOk3XYObFVBsUOAXEPL8usOd5Vte/z7eW3JVhnYKcqk5aHc7SsV9O/uuzhMM89t9GBmC7vwJGKuESwX8fus0UOk+eGnwEEHxa6qp/zTQuQ8E9WNl/wcVRy87vfoIhuA555Vi4BdjEp67 jjcanada@ual.es"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
  }

  tags {
    environment = "Terraform Demo"
  }
}
