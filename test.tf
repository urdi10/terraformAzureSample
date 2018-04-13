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
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags {
        environment = "Terraform Demo"
    }
}