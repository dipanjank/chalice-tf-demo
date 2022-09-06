variable "vpc_name" {
  type    = string
  default = "chalice-demo-vpc"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "vpc_azs" {
  type    = list(string)
  default = ["3	eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
variable "vpc_public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "3.14.4"
  name               = var.vpc_name
  cidr               = var.vpc_cidr
  azs                = var.vpc_azs
  private_subnets    = []
  public_subnets     = var.vpc_public_subnets
  enable_nat_gateway = false
  tags               = []
}
