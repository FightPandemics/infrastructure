provider "aws" {
  region  = var.aws_region
  version = "~> 2.70.0"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "fp_context" {
  type = string
}

variable "domain" {
  type = string
}
