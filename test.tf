provider "azurerm" {
}
resource "azureTerramorm-rg" "rg" {
        name = "azureTF-rg"
        location = "westus"
}