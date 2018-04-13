provider "azurerm" {
}
resource "azurerm_resource_group" "rg" {
        name = "azureTF-rg"
        location = "westus"
}