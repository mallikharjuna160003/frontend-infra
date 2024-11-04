pipeline {
    agent any

    environment {
        AWS_CREDENTIALS_ID = 'aws-access-key-id'  // Jenkins AWS credentials ID
        SLACK_WEBHOOK_URL = 'https://hooks.slack.com/services/...'
        FRONTEND_PATH = 'frontend'
        INFRA_PATH = '.'
        ALB_BACKEND = 'app-lb-638139560.us-west-2.elb.amazonaws.com'
        STATE_BUCKET = 'frontend-s3-bucket-123456'
        DYNAMODB_TABLE = 'frontend-lockfile'
        REGION = 'us-west-2'
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    echo "=== Cloning Repository ==="
                    git branch: 'main', url: 'https://github.com/mallikharjuna160003/frontend-infra.git'
                }
            }
        }

        stage('Create .env File') {
            steps {
                script {
                    echo "Creating environment file..."
                    writeFile file: "${FRONTEND_PATH}/.env", text: "REACT_APP_API_URL=${ALB_BACKEND}"
                }
            }
        }

        stage('Build Frontend') {
            steps {
                script {
                    echo "Building frontend..."
                    dir(FRONTEND_PATH) {
                        env.NODE_OPTIONS = '--openssl-legacy-provider'
                        sh 'npm install --legacy-peer-deps'
                        sh 'npm install --force'
                        sh 'npm run build'

                        // Check if the build directory exists
                        if (!fileExists("build")) {
                            error "Error: Build failed! Build directory not found."
                        }
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    echo "Initializing Terraform..."
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                        dir(INFRA_PATH) {
                            sh '''
                            terraform init -backend-config="bucket=${STATE_BUCKET}" \
                                           -backend-config="key=terraform/state" \
                                           -backend-config="region=${REGION}" \
                                           -backend-config="encrypt=true" \
                                           -backend-config="dynamodb_table=${DYNAMODB_TABLE}" \
                                           -reconfigure
                            '''
                        }
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    echo "Planning Terraform changes..."
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                        dir(INFRA_PATH) {
                            sh 'terraform plan'
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    echo "Applying Terraform changes..."
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                        dir(INFRA_PATH) {
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }

        stage('Get S3 Bucket Name') {
            steps {
                script {
                    echo "Getting deployment details..."
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                        BUCKET_NAME = sh(script: "cd ${INFRA_PATH} && terraform output -raw s3_bucket_name", returnStdout: true).trim()
    
                        if (BUCKET_NAME.isEmpty()) {
                            error "Error: Could not get bucket name from Terraform output"
                        }
                    }
                }
            }
        }

        stage('Upload to S3') {
            steps {
                script {
                    
                    echo "Uploading to S3..."
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                        dir(FRONTEND_PATH) {
                            if (sh(script: "aws s3 sync build/ s3://${BUCKET_NAME}", returnStatus: true) != 0) {
                                error "Error: S3 sync failed"
                            }
                        }
                    }
                }
            }
        }

        stage('Invalidate CloudFront Cache') {
            steps {
                script {
                    echo "Getting CloudFront domain..."
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                        CLOUDFRONT_DOMAIN = sh(script: "cd ${INFRA_PATH} && terraform output -raw cloudfront_domain", returnStdout: true).trim()
    
                        if (CLOUDFRONT_DOMAIN) {
                            echo "Invalidating CloudFront cache..."
                            DISTRIBUTION_ID = sh(script: "aws cloudfront list-distributions --query \"DistributionList.Items[?DomainName=='${CLOUDFRONT_DOMAIN}'].Id\" --output text", returnStdout: true).trim()
    
                            if (DISTRIBUTION_ID) {
                                if (sh(script: "aws cloudfront create-invalidation --distribution-id \"${DISTRIBUTION_ID}\" --paths \"/*\"", returnStatus: true) != 0) {
                                    echo "Warning: CloudFront invalidation failed"
                                }
                            } else {
                                echo "Warning: Could not find CloudFront distribution ID"
                            }
                        } else {
                            echo "Warning: Could not get CloudFront domain from Terraform output"
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                echo "=== Deployment Complete ==="
                echo "S3 Bucket: ${BUCKET_NAME}"
                if (CLOUDFRONT_DOMAIN) {
                    echo "Frontend URL: https://${CLOUDFRONT_DOMAIN}"
                }
                echo "Backend URL: http://${ALB_BACKEND}"

                // Send success notification to Slack
                slackNotification('Frontend infra Build succeeded!')
            }
        }
        failure {
            script {
                slackNotification('Frontend infra Build failed!')
            }
        }
        always {
            echo 'Pipeline completed.'
            cleanWs()
        }
    }
}

def slackNotification(String message) {
    sh """
    curl -X POST -H 'Content-type: application/json' --data '{"text":"${message}"}' ${SLACK_WEBHOOK_URL}
    """
}
