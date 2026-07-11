# ============================================================
# VPC VARIABLES
# ============================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_app_subnet_1_cidr" {
  description = "CIDR block for private app subnet 1"
  type        = string
  default     = "10.0.11.0/24"
}

variable "private_app_subnet_2_cidr" {
  description = "CIDR block for private app subnet 2"
  type        = string
  default     = "10.0.12.0/24"
}

variable "private_db_subnet_1_cidr" {
  description = "CIDR block for private database subnet 1"
  type        = string
  default     = "10.0.21.0/24"
}

variable "private_db_subnet_2_cidr" {
  description = "CIDR block for private database subnet 2"
  type        = string
  default     = "10.0.22.0/24"
}

# ============================================================
# EC2 VARIABLES
# ============================================================

variable "web_instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
}

variable "app_instance_type" {
  description = "EC2 instance type for app servers"
  type        = string
  default     = "t3.micro"
}

variable "web_min_size" {
  description = "Minimum number of web servers"
  type        = number
  default     = 1
}

variable "web_max_size" {
  description = "Maximum number of web servers"
  type        = number
  default     = 2
}

variable "app_min_size" {
  description = "Minimum number of app servers"
  type        = number
  default     = 1
}

variable "app_max_size" {
  description = "Maximum number of app servers"
  type        = number
  default     = 2
}

# ============================================================
# RDS VARIABLES
# ============================================================

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "production"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_backup_retention_days" {
  description = "Database backup retention (days)"
  type        = number
  default     = 35
}

# ============================================================
# COMPLIANCE CHECKER VARIABLES
# ============================================================

variable "email_address" {
  description = "Email for compliance notifications"
  type        = string
  default     = "stanleyjnrkanzara@gmail.com"
}

variable "compliance_check_schedule" {
  description = "EventBridge cron for compliance checks"
  type        = string
  default     = "cron(0 8 * * ? *)"
}

variable "enable_auto_remediation" {
  description = "Auto-fix critical violations"
  type        = bool
  default     = true
}

# ============================================================
# TAGGING VARIABLES
# ============================================================

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "three-tier-vpc"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}