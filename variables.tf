variable "bucket_name" {
  description = "Name of the S3 bucket"
  default     = "mern-chat-frontend-yourname" # Change this to a unique name
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "mern-chat"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "your-domain.com" # Replace with your domain
}
variable "elb_name" {
  description = "Domain name for the application"
  type        = string
  default     = "app-lb-638139560.us-west-2.elb.amazonaws.com" # Replace with your domain
}
