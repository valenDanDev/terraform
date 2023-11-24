terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  backend "local" {
    path = "C:/Users/LENOVO/Documents/SEMESTRE9/APLICACION PATRONES ARQ/terraform/itmiacstate.tfstate"
  }
}

# Configure and downloading plugins for AWS
provider "aws" {
  region = "${var.aws_region}"
  # profile = "${var.aws_profile}"
}