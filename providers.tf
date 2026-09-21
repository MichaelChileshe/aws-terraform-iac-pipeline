terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Applied to every resource this configuration creates — so everything is
  # tagged as Terraform-managed, which is exactly what the auditor wants to see.
  default_tags {
    tags = {
      Project    = "ubuntu-retail-webapp"
      ManagedBy  = "Terraform"
      Owner      = "michael-chileshe"
      CostCenter = "retail-ops"
    }
  }
}
