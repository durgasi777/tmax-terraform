variable "env" {
  type = string
  description = "Environment"
  default = "TradeMax"
}

variable "region" {
  type = string     
  description = "AWS Region"
  default = "ap-southeast-2"
}

variable "instance_type" {
  type = string
  description = "Instance Type"
  default = "t2.micro"
}

variable "image_id" {
  type = string
  description = "Custom AMI-ID"
  default = "ami-0b216a9fc227ebf67"
}

variable "key_name" {
  type = string
  description = "Pem Key"
  default = "karthik"
}

variable "vpc_id" {
  type = string
  description = "Default VPC"
  default = "vpc-c29492a5"
}

variable "subnet_ids" {
  type = list(string)
  description = "private subnet"
  default = ["subnet-5b4ea03d", "subnet-ba2932f3"]
}

variable "host_name" {
  type = string
  description = "Host Name"
  default = "kishoredurgasi.com"
}