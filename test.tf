provider "azurerm" {
}
resource "azurerm_resource_group" "myterraformgroup" {
        name = "azureTF-rg"
        location = "westus"

    tags {
        environment = "Terraform Demo"
    }

}