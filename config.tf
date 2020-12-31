# AWS Provider information - default location is $HOME/.aws/credentials
provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = "/home/ec2-user/environment/cablebuildergo/creds"
  profile                 = "AWS_CREDENTIALS_PROFILE"
  //access_key = var.aws_access_key
  //secret_key = var.aws_secret_key
}

terraform {
  backend "s3" {
    bucket         = "CBG_TERRAFORM_REMOTE_STATE"
    key            = "cablebuildergo/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    profile        = "AWS_CREDENTIALS_PROFILE"
   // dynamodb_table = "REMOTE_STATE_LOCK_TABLE"   //If used by multiple user then State locking 
   // kms_key_id = 
  }
}
