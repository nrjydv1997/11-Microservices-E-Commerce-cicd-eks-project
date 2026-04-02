terraform {
  
  required_version = ">=1.6.3"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">=5.25.0"
    }
  }

  backend "s3" {
    bucket = "11-microservices-terraform-state-nrjydv1997"
    key = "ecr/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt = true
  }

}