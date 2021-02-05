locals {
  project     = "schoolOfDevops"
  owner       = "ITs"
  environment = "Dev"
  description = "deleteme"
}


locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Project     = local.project
    Owner       = local.owner
    Environment = local.environment
    Description = local.description
  }
}

variable "aws-region" {
  type        = string
  description = "AWS Region to deploy resources to"
  default     = "ca-central-1"
}

variable "instance-type" {
  type    = string
  default = "t3.micro"
}

variable "registered_domain" {
  type        = string
  default     = "example.com"
  description = "Top level domain you own and administer with AWS Route 53"
}

variable "external_dns" {
  type        = string
  default     = "myapp.example.com"
  description = "A record to register for this app deployment. Must be subdomain of the registered_domain record."
}

variable "external_ip" {
  type    = string
  default = "78.78.78.78/32"
  description = "Your external IP that will be allowed through to connect to the EC2 jump"
}
