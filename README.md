It's our infrastructure module tree.

Terraform IaC Tree:

    terraform
    |--- config.tf     (aws & state file information) 
    |--- versions.tf
	|--- main.tf
	|--- variable.tf
	|--- terraform.tfvars    (Env values for the build)
	|--- output.tf 
	|__ modules
		|--- networking		(VPC & components)
		|	|--- main.tf
		|	|--- variables.tf
		|	|__ outputs.tf
		|
		|--- flowlog
		|	|--- main.tf
		|	|--- variables.tf
		|	|__ outputs.tf
		|
        |--- cloudtrail
		|	|--- main.tf
		|	|--- variables.tf
		|	|__ outputs.tf
		|
		|
        |--- security
		|	|--- main.tf
		|	|--- variables.tf
		|	|__ outputs.tf
		|
		|--- mysqlrds		
		|	|--- main.tf
		|	|--- variables.tf
		|	|__ outputs.tf
		|
        |--- iam			(Role for ec2 instance)
		|	|--- main.tf
		|	|--- variables.tf
		|	|__ outputs.tf
		|
		I__ compute		(ASG, ELB)
			|--- main.tf
			|--- variables.tf
			|--- tomcat_server_build.tmpl   (Shell script to build tomcat server)
			|__ outputs.tf

