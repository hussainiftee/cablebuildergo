# -----
# --- Config Module.
# -----

# AWS Provider information 
# default cred location is ~/.aws/credentials. If we are using Cloud9 then we cant use this location.
provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = "/home/ec2-user/environment/cablebuildergo/creds"
  profile                 = "AWS_CREDENTIALS_PROFILE"
}


# Terraform state file to construct the infratsructure.
# If getting credential Issue:  export AWS_SHARED_CREDENTIALS_FILE=/home/ec2-user/environment/cablebuildergo/creds
# Bucket created and protected Manually so that terraform should not control it.
terraform {
  backend "s3" {
    bucket  = "cablebuildergo-terraform-state"
    key     = "cablebuildergo/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
    profile = "AWS_CREDENTIALS_PROFILE"
    // dynamodb_table = "REMOTE_STATE_LOCK_TABLE"   //If used by multiple user then State locking 
    // kms_key_id = 
  }
}

# ----- End.