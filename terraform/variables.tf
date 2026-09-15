# ------------------------------------------------------------------
# General
# ------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region to deploy into. Mumbai by default since most of our users are in India."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short name used as prefix for pretty much every resource (e.g. myapp-vpc, myapp-alb)"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment name - dev / staging / prod. Gets tagged onto everything."
  type        = string
  default     = "prod"
}

# ------------------------------------------------------------------
# Networking
# ------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "How many AZs to spread subnets across. Mumbai (ap-south-1) has 3 AZs, but 2 is usually enough and cheaper."
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets (ALB + NAT gateway live here)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets (app servers + RDS live here)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "single_nat_gateway" {
  description = "true = 1 NAT gateway shared by all private subnets (cheaper, fine for most projects). false = one NAT per AZ (more resilient, costs more)."
  type        = bool
  default     = true
}

# ------------------------------------------------------------------
# App / EC2 / ASG
# ------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type for the app servers"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH access. Leave blank if you don't need SSH (recommended - use SSM Session Manager instead)."
  type        = string
  default     = ""
}

variable "app_port" {
  description = "Port your application listens on inside the instance"
  type        = number
  default     = 8080
}

variable "asg_min_size" {
  description = "Minimum number of app instances"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of app instances"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of app instances"
  type        = number
  default     = 2
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH into app boxes (only used if key_pair_name is set). Lock this down to your office/VPN IP, don't leave it 0.0.0.0/0."
  type        = string
  default     = "0.0.0.0/0"
}

# ------------------------------------------------------------------
# RDS (PostgreSQL)
# ------------------------------------------------------------------

variable "db_engine_version" {
  description = "Postgres engine version"
  type        = string
  default     = "15"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Upper limit for RDS storage autoscaling (GB). Set same as db_allocated_storage to disable autoscaling."
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Initial database name created on the RDS instance"
  type        = string
  default     = "myappdb"
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "myapp_admin"
}

variable "db_password" {
  description = "Master password for RDS. Pass this in via TF_VAR_db_password env var or a .tfvars file that is NOT committed to git - do not hardcode it."
  type        = string
  sensitive   = true
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS (recommended for prod, adds cost)"
  type        = bool
  default     = false
}

variable "db_backup_retention_days" {
  description = "How many days to keep automated RDS backups"
  type        = number
  default     = 0
}

variable "db_deletion_protection" {
  description = "Set true in real prod so nobody can accidentally terraform destroy the database"
  type        = bool
  default     = false
}
