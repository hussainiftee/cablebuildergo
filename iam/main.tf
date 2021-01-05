# -----
# --- IAM Main Module.
# ----- Create Profile/Role/Policy for application ec2 instance to get SSM and S3 access.


data "aws_iam_policy" "AmazonEC2RoleforSSM" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role" "ec2_cbg_role" {
  name               = "ec2_cablebuilder_role"
  assume_role_policy = "${file("./iam/assumerolepolicy.json")}"
}

resource "aws_iam_policy" "policy1" {
  name        = "cbg-tomcat-build"
  description = "S3 bucket access to configure Tomcat Application"
  policy      = "${file("./iam/policys3bucket.json")}"
}

resource "aws_iam_policy" "policy2" {
  name        = "parameter-store-access"
  description = "EC2 access to retrieve parameter"
  policy      = "${file("./iam/ParameterStoreAccess.json")}"
}

resource "aws_iam_policy_attachment" "cbg-attach1" {
  name       = "cbg-attachment1"
  roles      = [aws_iam_role.ec2_cbg_role.name]
  policy_arn = aws_iam_policy.policy1.arn
}

resource "aws_iam_policy_attachment" "cbg-attach2" {
  name       = "cbg-attachment2"
  roles      = [aws_iam_role.ec2_cbg_role.name]
  policy_arn = aws_iam_policy.policy2.arn
}

resource "aws_iam_policy_attachment" "cbg-attach3" {
  name       = "cbg-attachment3"
  roles      = [aws_iam_role.ec2_cbg_role.name]
  policy_arn = data.aws_iam_policy.AmazonEC2RoleforSSM.arn
} 

resource "aws_iam_instance_profile" "cbg_profile" {
  name  = "cbg_profile"
  role = aws_iam_role.ec2_cbg_role.name
}

# ----- End.  