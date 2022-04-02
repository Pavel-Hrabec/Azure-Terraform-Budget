terraform {
  backend "azure" {
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_budget" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_monitor_action_group" "monitor_budget" {
  name                = "Monitor-Budget"
  resource_group_name = azurerm_resource_group.rg_budget.name
  short_name          = "Budget"
}

resource "azurerm_consumption_budget_resource_group" "budget" {
  name              = "budget"
  resource_group_id = azurerm_resource_group.rg_budget.id

  amount     = var.budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = "2022-04-01T00:00:00Z"
    end_date   = "2024-04-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 1.0
    operator       = "EqualTo"
    threshold_type = "Forecasted"

    contact_emails = [
      var.contact_email,
    ]

    contact_groups = [
      azurerm_monitor_action_group.monitor_budget.id,
    ]

  }

}