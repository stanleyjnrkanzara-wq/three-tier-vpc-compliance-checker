# ============================================================
# VPC OUTPUTS
# ============================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

# ============================================================
# SUBNET OUTPUTS
# ============================================================

output "public_subnets" {
  description = "Public subnet IDs"
  value = {
    subnet_1 = aws_subnet.public_1.id
    subnet_2 = aws_subnet.public_2.id
  }
}

output "private_app_subnets" {
  description = "Private app subnet IDs"
  value = {
    subnet_1 = aws_subnet.private_app_1.id
    subnet_2 = aws_subnet.private_app_2.id
  }
}

output "private_db_subnets" {
  description = "Private database subnet IDs"
  value = {
    subnet_1 = aws_subnet.private_db_1.id
    subnet_2 = aws_subnet.private_db_2.id
  }
}

# ============================================================
# LOAD BALANCER OUTPUTS
# ============================================================

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

# ============================================================
# AUTO SCALING GROUP OUTPUTS
# ============================================================

output "web_asg_name" {
  description = "Web tier Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}

output "app_asg_name" {
  description = "App tier Auto Scaling Group name"
  value       = aws_autoscaling_group.app.name
}

# ============================================================
# DATABASE OUTPUTS
# ============================================================

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "rds_engine" {
  description = "RDS database engine"
  value       = aws_db_instance.main.engine
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.main.db_name
}

# ============================================================
# SECURITY GROUP OUTPUTS
# ============================================================

output "web_tier_sg_id" {
  description = "Web tier security group ID"
  value       = aws_security_group.web_tier.id
}

output "app_tier_sg_id" {
  description = "App tier security group ID"
  value       = aws_security_group.app_tier.id
}

output "db_tier_sg_id" {
  description = "Database tier security group ID"
  value       = aws_security_group.db_tier.id
}

# ============================================================
# COMPLIANCE CHECKER OUTPUTS
# ============================================================

output "compliance_sns_topic_arn" {
  description = "SNS topic ARN for compliance alerts"
  value       = aws_sns_topic.compliance_alerts.arn
}

output "compliance_checker_log_group" {
  description = "CloudWatch log group for compliance checker"
  value       = aws_cloudwatch_log_group.compliance_checker.name
}

# ============================================================
# DEPLOYMENT SUMMARY
# ============================================================

output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    environment     = var.environment
    region          = var.aws_region
    vpc_id          = aws_vpc.main.id
    vpc_cidr        = aws_vpc.main.cidr_block
    alb_dns         = aws_lb.main.dns_name
    rds_endpoint    = aws_db_instance.main.endpoint
    web_asg_min     = aws_autoscaling_group.web.min_size
    web_asg_max     = aws_autoscaling_group.web.max_size
    app_asg_min     = aws_autoscaling_group.app.min_size
    app_asg_max     = aws_autoscaling_group.app.max_size
  }
}