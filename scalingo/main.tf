# Set the required provider and versions
terraform {
  required_providers {
    scalingo = {
      source  = "scalingo/scalingo"
      version = "2.3.0" # Or the latest version
    }
  }
}

variable "scalingo_token" {
  type        = string
  description = "the scalingo token"
}

provider "scalingo" {
  api_token = var.scalingo_token
  region    = "osc-fr1"
}

resource "scalingo_app" "loisefenoll-python-api" {
  name     = "loisefenoll-python-api"
}

resource "scalingo_addon" "db" {
  provider_id = "mysql"
  plan = "mysql-starter-512"
  app = "${scalingo_app.loisefenoll-python-api.id}"
}

resource "scalingo_container_type" "web" {
  app    = scalingo_app.loisefenoll-python-api.name
  name   = "web"
  amount = 1
  size   = "S"
}

resource "scalingo_container_type" "api" {
  app    = scalingo_app.loisefenoll-python-api.name
  name   = "api"
  amount = 1
  size   = "S"
}


