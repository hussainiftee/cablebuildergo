#!/bin/bash -xe
exec > >(tee /var/log/user-data1.log|logger -t user-data1 -s 2>/dev/console) 2>&1
set -x
/bin/cp -rf /opt/tomcat/conf/Catalina/localhost/context.xml-reuse /opt/tomcat/conf/Catalina/localhost/context.xml
export rds_password=`aws --region=${aws_region} ssm get-parameter --name "/production/cablebuildergo/password/admin" --with-decryption --output text --query Parameter.Value`
/usr/bin/sed -i 's/DbPassword/'"$rds_password"'/g' /opt/tomcat/conf/Catalina/localhost/context.xml
# end.
