/*provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}*/

data "aws_iam_policy" "AmazonEC2RoleforSSM" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role" "ec2_cbg_role" {
  name               = "ec2_cablebuilder_role"
  assume_role_policy = "${file("./iam/assumerolepolicy.json")}"
}

resource "aws_iam_policy" "policy" {
  name        = "cbg-tomcat-build"
  description = "S3 bucket access to configure Tomcat Application"
  policy      = "${file("./iam/policys3bucket.json")}"
}

resource "aws_iam_policy_attachment" "cbg-attach1" {
  name       = "cbg-attachment1"
  roles      = [aws_iam_role.ec2_cbg_role.name]
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_policy_attachment" "cbg-attach2" {
  name       = "cbg-attachment2"
  roles      = [aws_iam_role.ec2_cbg_role.name]
  policy_arn = data.aws_iam_policy.AmazonEC2RoleforSSM.arn
  
  /*lifecycle {
    ignore_changes = ["roles"]
  }*/
} 

resource "aws_iam_instance_profile" "cbg_profile" {
  name  = "cbg_profile"
  role = aws_iam_role.ec2_cbg_role.name
}