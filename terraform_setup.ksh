#!bin/bash -xe
sudo yum install unzip
sudo yum update -y
sudo curl -O https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip
sudo mkdir /bin/terraform 
sudo unzip terraform_0.12.5_linux_amd64.zip -d /usr/local/bin/
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa 2>/dev/null <<< y >/dev/null
