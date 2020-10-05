terraform {
  required_version = ">= 0.12.20"

  backend "s3" {
    bucket = "durgasi-terraform-state"
    region = "ap-southeast-2"
    key    = "trademax/terraform.tfstate"
    encrypt = true
  }
}
