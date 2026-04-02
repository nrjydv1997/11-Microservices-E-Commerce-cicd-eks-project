variable "bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "11-microservices-terraform-state-nrjydv1997"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-lock"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}