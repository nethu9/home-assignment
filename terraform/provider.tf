terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "temperature-rg"
    storage_account_name = "tfsavestate"
    container_name = "terraform"
    key = "terraform.tfstate"

  }
}
provider "azurerm" {
  features {}
}