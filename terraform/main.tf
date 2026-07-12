terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-vpc"
    }
  )
}

# ============================================================
# INTERNET GATEWAY
# ============================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-igw"
    }
  )
}

# ============================================================
# PUBLIC SUBNETS (Web Tier)
# ============================================================

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-public-subnet-1"
      Tier = "Public"
    }
  )
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-public-subnet-2"
      Tier = "Public"
    }
  )
}

# ============================================================
# PRIVATE SUBNETS (App Tier)
# ============================================================

resource "aws_subnet" "private_app_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_1_cidr
  availability_zone = "${var.aws_region}a"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-private-app-subnet-1"
      Tier = "Private-App"
    }
  )
}

resource "aws_subnet" "private_app_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_2_cidr
  availability_zone = "${var.aws_region}b"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-private-app-subnet-2"
      Tier = "Private-App"
    }
  )
}

# ============================================================
# PRIVATE SUBNETS (Database Tier)
# ============================================================

resource "aws_subnet" "private_db_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_1_cidr
  availability_zone = "${var.aws_region}a"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-private-db-subnet-1"
      Tier = "Private-Database"
    }
  )
}

resource "aws_subnet" "private_db_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_2_cidr
  availability_zone = "${var.aws_region}b"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-private-db-subnet-2"
      Tier = "Private-Database"
    }
  )
}

# ============================================================
# ROUTE TABLES - PUBLIC
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-public-rt"
    }
  )
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# ============================================================
# ROUTE TABLES - PRIVATE APP (Use IGW for lite version)
# ============================================================

resource "aws_route_table" "private_app_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-private-app-rt-1"
    }
  )
}

resource "aws_route_table_association" "private_app_1" {
  subnet_id      = aws_subnet.private_app_1.id
  route_table_id = aws_route_table.private_app_1.id
}

resource "aws_route_table" "private_app_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-private-app-rt-2"
    }
  )
}

resource "aws_route_table_association" "private_app_2" {
  subnet_id      = aws_subnet.private_app_2.id
  route_table_id = aws_route_table.private_app_2.id
}

# ============================================================
# ROUTE TABLES - PRIVATE DATABASE (No Internet)
# ============================================================

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-private-db-rt"
    }
  )
}

resource "aws_route_table_association" "private_db_1" {
  subnet_id      = aws_subnet.private_db_1.id
  route_table_id = aws_route_table.private_db.id
}

resource "aws_route_table_association" "private_db_2" {
  subnet_id      = aws_subnet.private_db_2.id
  route_table_id = aws_route_table.private_db.id
}

# ============================================================
# VPC FLOW LOGS
# ============================================================

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${var.environment}"
  retention_in_days = 7

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-vpc-flow-logs"
    }
  )
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "${var.environment}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-vpc-flow-logs"
    }
  )
}

# ============================================================
# SECURITY GROUPS
# ============================================================

resource "aws_security_group" "web_tier" {
  name_prefix = "${var.environment}-web-tier-"
  description = "Security group for web tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-web-tier-sg"
    }
  )
}

resource "aws_security_group" "app_tier" {
  name_prefix = "${var.environment}-app-tier-"
  description = "Security group for app tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-app-tier-sg"
    }
  )
}

resource "aws_security_group" "db_tier" {
  name_prefix = "${var.environment}-db-tier-"
  description = "Security group for database tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-db-tier-sg"
    }
  )
}

# ============================================================
# APPLICATION LOAD BALANCER
# ============================================================

resource "aws_lb" "main" {
  name_prefix        = "app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_tier.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-alb"
    }
  )
}

resource "aws_lb_target_group" "web" {
  name_prefix = "web"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-web-tg"
    }
  )
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# ============================================================
# LAUNCH TEMPLATES
# ============================================================

resource "aws_launch_template" "web" {
  name_prefix   = "${var.environment}-web-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.web_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_tier.id]
  }

  user_data = base64encode(templatefile("${path.module}/user_data_web.sh", {
    environment = var.environment
  }))

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.environment}-web-instance"
        Tier = "Public"
      }
    )
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-app-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.app_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_tier.id]
  }

  user_data = base64encode(templatefile("${path.module}/user_data_app.sh", {
    environment = var.environment
    db_endpoint = aws_db_instance.main.endpoint
  }))

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.environment}-app-instance"
        Tier = "Private-App"
      }
    )
  }
}

# ============================================================
# AUTO SCALING GROUPS
# ============================================================

resource "aws_autoscaling_group" "web" {
  name_prefix         = "${var.environment}-web-asg-"
  min_size            = var.web_min_size
  max_size            = var.web_max_size
  desired_capacity    = var.web_min_size
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-web-asg"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_group" "app" {
  name_prefix         = "${var.environment}-app-asg-"
  min_size            = var.app_min_size
  max_size            = var.app_max_size
  desired_capacity    = var.app_min_size
  vpc_zone_identifier = [aws_subnet.private_app_1.id, aws_subnet.private_app_2.id]
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-app-asg"
    propagate_at_launch = false
  }
}

# ============================================================
# EC2 IAM ROLE
# ============================================================

resource "aws_iam_role" "ec2_role" {
  name_prefix = "${var.environment}-ec2-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "${var.environment}-ec2-profile-"
  role        = aws_iam_role.ec2_role.name
}

# ============================================================
# RDS AURORA MYSQL
# ============================================================

resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.environment}-db-subnet-group-"
  subnet_ids  = [aws_subnet.private_db_1.id, aws_subnet.private_db_2.id]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-db-subnet-group"
    }
  )
}

resource "aws_db_instance" "main" {
  identifier                  = "${var.environment}-mysql-db"
  engine                      = "mysql"
  engine_version              = "8.0"
  instance_class              = var.db_instance_class
  allocated_storage           = var.db_allocated_storage
  storage_type                = "gp3"

  db_name                     = var.db_name
  username                    = var.db_username
  password                    = var.db_password
  db_subnet_group_name        = aws_db_subnet_group.main.name
  vpc_security_group_ids      = [aws_security_group.db_tier.id]

  multi_az                    = true
  publicly_accessible         = false

  backup_retention_period     = var.db_backup_retention_days
  backup_window               = "03:00-04:00"
  maintenance_window          = "sun:04:00-sun:05:00"

  skip_final_snapshot         = false
  final_snapshot_identifier   = "${var.environment}-mysql-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  deletion_protection         = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-mysql-db"
    }
  )
}

# ============================================================
# SNS TOPIC FOR COMPLIANCE ALERTS
# ============================================================

resource "aws_sns_topic" "compliance_alerts" {
  name         = "${var.environment}-compliance-alerts"
  display_name = "VPC Compliance Alerts"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-compliance-alerts"
    }
  )
}

resource "aws_sns_topic_subscription" "compliance_email" {
  topic_arn = aws_sns_topic.compliance_alerts.arn
  protocol  = "email"
  endpoint  = var.email_address
}

# ============================================================
# CLOUDWATCH LOG GROUP FOR LAMBDA
# ============================================================

resource "aws_cloudwatch_log_group" "compliance_checker" {
  name              = "/aws/lambda/${var.environment}-compliance-checker"
  retention_in_days = 7

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-compliance-checker-logs"
    }
  )
}

# ============================================================
# DATA SOURCE: Amazon Linux 2 AMI
# ============================================================

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}