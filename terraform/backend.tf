# ------------------------------------------------------------------
# Remote state config
# We keep tfstate in S3 (versioned bucket) + use a DynamoDB table for
# locking so two people don't run apply at the same time and blow
# up the state file. Bucket + table need to exist BEFORE you run
# `terraform init` here - see bootstrap/ folder or README for the
# one-time setup commands.
#
# NOTE: bucket names are global across all of AWS, so
# "myapp-terraform-state-mumbai" WILL clash with someone else's.
# Change it to something unique for your org before init.
# ------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "8byte-terraform-state-432500708653"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "myapp-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
