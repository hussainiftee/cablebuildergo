# Terraform & its module versions required for the code.

terraform {
  required_version = ">= 0.12.5"

  required_providers {
    aws      = ">= 2.68"
    template = ">= 2.2"
    random   = ">= 2.2"
  }
}

# ----- End.  