variable "region" {
  description = "AWS region for the landing zone."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Named AWS CLI profile to use. Prefer an SSO profile over an IAM user access key."
  type        = string
  default     = "terraform-lab"
}

variable "env" {
  description = "Environment name. Used in resource names and tags."
  type        = string
  default     = "pathfinder"
}

variable "wbs_id" {
  description = "Work breakdown structure element this infrastructure belongs to. Tagged onto every resource so AWS spend can be mapped back to the cost baseline."
  type        = string
  default     = "2.0"
}

variable "vpc_cidr" {
  description = "CIDR block for the landing zone VPC. Must not overlap the simulated on-premises range."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block, for example 10.20.0.0/16."
  }
}

variable "az_count" {
  description = "Number of Availability Zones to spread subnets across."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}

variable "source_public_ip" {
  description = "Public IP of your home network in CIDR form, e.g. 203.0.113.45/32. Replication traffic on port 1500 is accepted only from here. Find it with: curl -s https://checkip.amazonaws.com"
  type        = string

  validation {
    condition     = can(cidrhost(var.source_public_ip, 0))
    error_message = "source_public_ip must be in CIDR form, for example 203.0.113.45/32."
  }
}

variable "admin_ip" {
  description = "CIDR allowed to reach migrated instances over SSH. Usually the same as source_public_ip."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_ip, 0))
    error_message = "admin_ip must be in CIDR form, for example 203.0.113.45/32."
  }
}

variable "db_port" {
  description = "Database port the application tier connects on. 3306 MySQL, 5432 PostgreSQL."
  type        = number
  default     = 3306
}
