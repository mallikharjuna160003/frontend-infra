# Backend infra pipeline

# Installing jenkins on jenkins container 
```sh
docker exec -it --user root jenkins bash
apt-get update && apt-get install -y git
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws
apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com bookworm main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update && apt-get install -y terraform
exit
```
jenkins running on http://localhost:8080


## Terraform and aws cli Setup on jenkins container:
```sh
docker exec -it --user root jenkins bash

# Download Terraform (change the version as needed)
curl -LO https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip

# Install unzip if not already installed
apt-get update && apt-get install -y unzip

# Unzip and move to /usr/local/bin
unzip terraform_1.6.0_linux_amd64.zip
mv terraform /usr/local/bin/

# Verify Terraform installation
terraform -version

# Install the AWS CLI
apt-get install -y python3-pip
pip3 install awscli --upgrade --user

# Verify AWS CLI installation
aws --version
```

# slack notification setup 
- Created slack app and added the workspace i already have then generated the webhook.
```sh
Webhook
https://hooks.slack.com/services/<token>
```

# configured the jenkins credentials

```sh
docker hub token:
ID: docker-hub-credentials:
Token:  
<token-generated-from-docker-hub>

ID: 
github-credentials
Token:
<token-generated-from-github>


ID:
aws-access-key-id

Access Key ID
<access-key-generated-from-aws-console>

Secret Access Key
<token-generated-from-aws-console>


```

# Installing docker in jenkins container
```sh
docker exec -it --user root jenkins bash
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
docker --version
```

# Jenkins container backeup
with the below commands I created the jenkins backup. and mounted with new jenkins container.
```sh
docker stop jenkins

docker cp jenkins:/var/jenkins_home /home/sunkara/jenkins_home_backup

docker rm jenkins

docker run \
    --name jenkins \
    -p 8080:8080 \
    -p 50000:50000 \
    -v /home/sunkara/jenkins_home_backup:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --privileged \
    jenkins/jenkins:lts
	
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

# Jenkins Plugins 

Go to Manage Jenkins > Manage Plugins.
In the Available tab, search for and install the following plugins:
- Git Plugin
- Pipeline Plugin
- AWS Steps
- Slack Notification Plugin (if you plan to use Slack notifications).
- nodejs

# AWS Configure configuration in jenkins container
```sh
docker exec -it --user root jenkins bash
aws configure
AWS Access Key ID [None]: <access-key-generated-from-aws-console>
AWS Secret Access Key [None]: <token-generated-from-aws-console>
Default region name [<token-generated-from-aws-console>]: <region>
Default output format [json]: json
```
# AWS S3 bucket terraform state file and state lock file in dynamodb as  remote backend
storing the terraform state files in s3 bucket and state lock file in dynamodb. Below command used to create the resource.
```sh
aws dynamodb create-table   --table-name frontend-lockfile   --attribute-definitions AttributeName=LockID,AttributeType=S   --key-schema AttributeName=LockID,KeyType=HASH   --billing-mode PAY_PER_REQUEST


aws dynamodb create-table \
  --table-name frontend-lockfile \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-west-2
  
  
 aws s3api create-bucket --bucket frontend-s3-bucket-123456 --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2

aws s3api put-bucket-versioning --bucket frontend-s3-bucket-123456 --versioning-configuration Status=Enabled
```
.env file backend loabalancer as url to react app
```sh
REACT_APP_API_URL="http://app-lb-638139560.us-west-2.elb.amazonaws.com"
```

# Frontend Architecture

![cs7-640x408](https://github.com/user-attachments/assets/39893282-7432-4ef4-a9d5-34725eeaa380)



# Recommended for Production architecture
We need to register Route53 domain or any public hosted domain names attaching to cloudfront endpoint. It is more secure and reliable.
![1_j-Px5fIzUWj42Qe4tAtOag](https://github.com/user-attachments/assets/a1f070d8-f9d9-4d3e-ab9e-f1fad3c55671)

  
  
  
  
  
  

```
