#!/bin/bash

# Set paths
FRONTEND_PATH="frontend"
INFRA_PATH="    frontend-infra"
ALB_BACKEND="app-lb-638139560.us-west-2.elb.amazonaws.com"
STATE_BUCKET="frontend-s3-bucket-123456"
DYNAMODB_TABLE="frontend-lockfile"
REGION="us-west-2"

echo "=== Starting Frontend Deployment ==="

# Create .env file with backend URL
echo "Creating environment file..."
echo "REACT_APP_API_URL=${ALB_BACKEND}" > $FRONTEND_PATH/.env

# Build frontend
echo "Building frontend..."
cd $FRONTEND_PATH
export NODE_OPTIONS=--openssl-legacy-provider
npm run build

if [ ! -d "build" ]; then
    echo "Error: Build failed! Build directory not found."
    exit 1
fi

# # Set up Terraform backend configuration in infra path
# echo "Configuring Terraform backend..."
# cat > "$INFRA_PATH/backend.tf" <<EOF
# terraform {
#   backend "s3" {
#     bucket = "${STATE_BUCKET}"
#     key    = "frontend-infrastructure/terraform.tfstate"
#     region = "${REGION}"
#     dynamodb_table = "${DYNAMODB_TABLE}"
#     encrypt = true
#   }
# }
# EOF

# Deploy infrastructure using Terraform
echo "Deploying infrastructure..."
cd $INFRA_PATH
terraform init -input=false
if ! terraform apply -auto-approve -input=false; then
    echo "Error: Terraform apply failed"
    exit 1
fi

# Get S3 bucket name from Terraform output
echo "Getting deployment details..."
BUCKET_NAME=$(terraform output -raw s3_bucket_name || echo "")

if [ -z "$BUCKET_NAME" ]; then
    echo "Error: Could not get bucket name from Terraform output"
    exit 1
fi

# Upload to S3
echo "Uploading to S3..."
cd $FRONTEND_PATH
if ! aws s3 sync build/ s3://$BUCKET_NAME; then
    echo "Error: S3 sync failed"
    exit 1
fi

# Get CloudFront domain and distribution ID
CLOUDFRONT_DOMAIN=$(cd $INFRA_PATH && terraform output -raw cloudfront_domain || echo "")

if [ ! -z "$CLOUDFRONT_DOMAIN" ]; then
    echo "Invalidating CloudFront cache..."
    DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?DomainName=='$CLOUDFRONT_DOMAIN'].Id" --output text)

    if [ ! -z "$DISTRIBUTION_ID" ]; then
        if ! aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*"; then
            echo "Warning: CloudFront invalidation failed"
        fi
    else
        echo "Warning: Could not find CloudFront distribution ID"
    fi
else
    echo "Warning: Could not get CloudFront domain from Terraform output"
fi

echo "=== Deployment Complete ==="
echo "S3 Bucket: $BUCKET_NAME"
if [ ! -z "$CLOUDFRONT_DOMAIN" ]; then
    echo "Frontend URL: https://$CLOUDFRONT_DOMAIN"
fi
echo "Backend URL: http://${ALB_BACKEND}"

