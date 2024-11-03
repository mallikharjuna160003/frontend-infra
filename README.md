# Frontend Architecture

![cs7-640x408](https://github.com/user-attachments/assets/39893282-7432-4ef4-a9d5-34725eeaa380)


## Remote backend 
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
  
  
  
  
  
  
  

```
