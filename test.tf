provider "azurerm" {
}
resource "azurerm_resource_group" "myterraformgroup" {
        name = "azureTF-rg"
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