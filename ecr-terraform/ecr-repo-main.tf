provider "aws" {
  region = "ap-south-1"
}

locals {
  services = [
    "emailservice",
    "checkoutservice",
    "recommendationservice",
    "frontend",
    "paymentservice",
    "productcatalogservice",
    "cartservice",
    "loadgenerator",
    "currencyservice",
    "shippingservice",
    "adservice"
  ]
}

resource "aws_ecr_repository" "services" {
  for_each = toset(local.services)

  name = each.value

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  #Delete all images before deleting repository
  force_delete = true

  tags = {
    Environment = "dev"
    services = each.value
  }
}