terraform {
  required_version = ">= 1.10, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Remote state. The bucket is created once by hand (see README.md in this
  # directory) because the state backend must exist before Terraform can manage
  # anything. This is the bootstrapping problem and it is deliberate, not an
  # oversight. Recorded as ADR-004.
  #
  # Values are supplied at init time from backend.hcl, which is gitignored:
  #   terraform init -backend-config=backend.hcl
  backend "s3" {}
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile

  # Every resource inherits these. The WBS tag is what makes cost variance
  # analysis possible later: spend can be queried per work package.
  default_tags {
    tags = {
      Project   = "dc-exit-capstone"
      ManagedBy = "Terraform"
      Env       = var.env
      WBS       = var.wbs_id
    }
  }
}
