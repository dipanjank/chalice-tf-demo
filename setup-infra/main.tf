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
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
variable "vpc_public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "vpc_private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "3.14.4"
  name               = var.vpc_name
  cidr               = var.vpc_cidr
  azs                = var.vpc_azs
  private_subnets    = var.vpc_private_subnets
  public_subnets     = var.vpc_public_subnets
  enable_nat_gateway = true
  tags = {
    Name = "chalice-demo-vpc"
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Default SG for our demo Lambda functions."
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Allow all Inbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all Outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "allow_all"
  }
}

resource "aws_s3_bucket" "input_bucket" {
  bucket = "chalice-demo-input-bucket"

  tags = {
    Name = "chalice-demo-input-bucket"
  }
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "chalice-demo-output-bucket"

  tags = {
    Name = "chalice-demo-output-bucket"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "chalice-demo-lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_role_policy" {
  name = "chalice-demo-lambda_role-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:*",
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:*",
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:*",
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach-lambda-role-to-policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_role_policy.arn
}

resource "aws_sqs_queue" "chalice_demo_queue" {
  name = "sum-rows-queue"
}
