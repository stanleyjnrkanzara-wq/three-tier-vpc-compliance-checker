#  Three-Tier VPC Architecture

## Overview

This document describes the complete architecture of the three-tier VPC with automated compliance checking.

## Network Design Philosophy

The three-tier architecture enforces **defense in depth** through network isolation:

```bash
Internet
        ↓ (HTTP/HTTPS only)
┌─────────────────────┐
│  Public Tier (Web)  │ ← Can be accessed from internet
├─────────────────────┤
│  Ingress: 80, 443   │ ← Restricted to HTTP/HTTPS
│  Egress: All        │ ← Can reach app tier
└─────────────────────┘
        ↓ (Internal only)
┌─────────────────────┐
│ Private Tier (App)  │ ← CANNOT be accessed from internet
├─────────────────────┤
│  Ingress: 8080      │ ← Only from web tier
│  Egress: All        │ ← Can reach database tier
└─────────────────────┘
         ↓ (Internal only)
┌─────────────────────┐
│ Private Tier (DB)   │ ← CANNOT be accessed from internet
├─────────────────────┤
│  Ingress: 3306      │ ← Only from app tier
│  Egress: None       │ ← Database shouldn't initiate connections
└─────────────────────┘

```
---

## Network Topology

### VPC Structure

```bash

VPC CIDR: 10.0.0.0/16 (65,536 addresses)
Public Subnets (Web Tier):
├─ Subnet 1A: 10.0.1.0/24 (us-east-1a)
│  └─ ALB: 10.0.1.x
│  └─ Web Servers: 10.0.1.x
│
└─ Subnet 1B: 10.0.2.0/24 (us-east-1b)
└─ ALB: 10.0.2.x
└─ Web Servers: 10.0.2.x
Private App Subnets (Application Tier):
├─ Subnet 1A: 10.0.11.0/24 (us-east-1a)
│  └─ App Servers: 10.0.11.x
│
└─ Subnet 1B: 10.0.12.0/24 (us-east-1b)
└─ App Servers: 10.0.12.x
Private Database Subnets (Database Tier):
├─ Subnet 1A: 10.0.21.0/24 (us-east-1a)
│  └─ RDS Replica: 10.0.21.x
│
└─ Subnet 1B: 10.0.22.0/24 (us-east-1b)
└─ RDS Primary: 10.0.22.x

```
---

## Availability Zones

All tiers are distributed across **2 Availability Zones** for high availability:

```bash

Availability Zone A (us-east-1a)
├─ Public Subnet: 10.0.1.0/24
├─ App Subnet: 10.0.11.0/24
├─ DB Subnet: 10.0.21.0/24
├─ EC2 Web: 10.0.1.10
├─ EC2 App: 10.0.11.10
└─ RDS Replica: 10.0.21.10
Availability Zone B (us-east-1b)
├─ Public Subnet: 10.0.2.0/24
├─ App Subnet: 10.0.12.0/24
├─ DB Subnet: 10.0.22.0/24
├─ EC2 Web: 10.0.2.10
├─ EC2 App: 10.0.12.10
└─ RDS Primary: 10.0.22.10
```
---

**Benefits:**
- ✅ If AZ-a fails, AZ-b continues running
- ✅ ALB automatically routes to healthy instances
- ✅ RDS automatically fails over to replica
- ✅ Zero downtime during AZ failure

## Security Groups (Stateful Firewall)

### Web Tier Security Group

```bash
Inbound Rules:
├─ Port 80 (HTTP) from 0.0.0.0/0 (internet)
└─ Port 443 (HTTPS) from 0.0.0.0/0 (internet)
Outbound Rules:
└─ All traffic to 0.0.0.0/0 (can reach app tier + internet)

```
---

### App Tier Security Group

```bash

Inbound Rules:
└─ Port 8080 from web-tier-sg ONLY (not from internet)
Outbound Rules:
└─ All traffic to 0.0.0.0/0 (can reach database tier)

```
---

### Database Tier Security Group

```bash

Inbound Rules:
└─ Port 3306 (MySQL) from app-tier-sg ONLY
Outbound Rules:
└─ None (database should NOT initiate outbound)

```
---

## Traffic Flow

### User to Web Server

```bash

User Browser (203.0.113.50:54321)
            ↓
         Internet
            ↓
ALB (10.0.1.5:80 and 10.0.2.5:80)
            ↓ (Distributes to healthy targets)
Web Server 1 (10.0.1.10:80) OR Web Server 2 (10.0.2.10:80)

```
---

### Web Server to App Server

```bash
Web Server (10.0.1.10:54321)
↓
VPC Internal Network (no internet charges)
↓
App Server (10.0.11.10:8080) OR (10.0.12.10:8080)
✅ Allowed by security group (port 8080 from web-tier-sg)

```
---

### App Server to Database

```bash
App Server (10.0.11.10:54321)
↓
VPC Internal Network (encrypted with SSL/TLS)
↓
RDS Endpoint (10.0.21.10:3306 or 10.0.22.10:3306)
✅ Allowed by security group (port 3306 from app-tier-sg)
✅ Connection requires SSL/TLS (parameter: require_secure_transport=1)

```
---

## Routing

### Public Route Table

```bash

Destination    | Target        | Type
───────────────|────────────── |─────────────
10.0.0.0/16   | Local         | Local (VPC internal)
0.0.0.0/0     | igw-xxxxx     | Internet Gateway

When a public instance sends traffic to the internet:
1. Packet destined for 203.0.113.50:443
2. Route table matches 0.0.0.0/0
3. Sends to Internet Gateway
4. IGW forwards to internet

```
---
### Private App Route Table

```bash

Destination    | Target        | Type
───────────────|────────────── |─────────────
10.0.0.0/16   | Local         | Local (VPC internal)
0.0.0.0/0     | igw-xxxxx     | Internet Gateway (for testing)

**Note:** In production, this would use NAT Gateway. For testing, we use IGW to save costs.

```
---

### Private Database Route Table

```bash

Destination    | Target        | Type
───────────────|────────────── |─────────────
10.0.0.0/16   | Local         | Local (VPC internal)
(No default route)

Database tier has NO route to internet (intentional isolation).

```
---

## Load Balancer

### Application Load Balancer (ALB)

```bash

External IP: 203.0.113.200 (managed by AWS)
Internal IPs: 10.0.1.5 (subnet 1A) + 10.0.2.5 (subnet 1B)
Health Checks:
├─ Target Group: port 80, path "/"
├─ Interval: 30 seconds
├─ Timeout: 3 seconds
├─ Healthy threshold: 2 consecutive checks
└─ Unhealthy threshold: 2 consecutive checks
Target Routing:
└─ Route all port 80 traffic to web servers (10.0.1.10, 10.0.2.10)

```
---
## Auto Scaling

### Web Tier Auto Scaling Group

```bash

Name: dev-web-asg
Min Size: 1
Max Size: 2
Desired: 1
Scaling Policy:
├─ Scale UP when CPU > 70% for 2 minutes
└─ Scale DOWN when CPU < 30% for 5 minutes
Health Check:
├─ Type: ELB (via load balancer)
├─ Grace Period: 300 seconds
└─ Replaces unhealthy instances automatically

```
---

### App Tier Auto Scaling Group

```bash

Name: dev-app-asg
Min Size: 1
Max Size: 2
Desired: 1
Scaling Policy:
├─ Scale UP when CPU > 70% for 2 minutes
└─ Scale DOWN when CPU < 30% for 5 minutes
Health Check:
├─ Type: EC2 (based on instance status)
└─ Replaces unhealthy instances automatically

```
---

## Database (RDS Aurora MySQL)

### Configuration

```bash

Engine: MySQL 8.0.35
Instance Type: db.t3.micro (free tier) or db.t3.small (production)
Storage: 100 GB gp3 (auto-scaling)
Multi-AZ: YES (automatic failover)
Availability Zones: us-east-1a (primary) + us-east-1b (replica)

```
---

### Encryption

```bash

At Rest:
├─ Encryption: AES-256 (AWS managed)
├─ Storage: Encrypted by default
└─ Snapshots: Encrypted
In Transit:
├─ SSL/TLS: REQUIRED
├─ Parameter: require_secure_transport = 1
└─ Connections must use SSL/TLS

```
---

### Backups

```bash

Automated Backups:
├─ Retention: 35 days
├─ Window: 03:00-04:00 UTC daily
├─ Multi-AZ: YES (backed up in both AZs)
└─ Point-in-time recovery available
Manual Snapshots:
└─ Created before terraform destroy

```
---
### Security

```bash

Network:
├─ Publicly Accessible: NO
├─ Security Group: db-tier-sg (port 3306 only)
└─ VPC: Inside VPC (no internet access)
Deletion Protection: YES

```
---

## VPC Flow Logs

```bash

All traffic in/out of the VPC is logged:
Source: All network interfaces
Destination: CloudWatch Logs
Log Group: /aws/vpc/flowlogs/dev
Retention: 7 days
Traffic Type: ALL (both accepted and rejected)
Fields Logged:
├─ Source IP / Port
├─ Destination IP / Port
├─ Protocol
├─ Packets
├─ Bytes
├─ Accept / Reject
└─ Timestamp

```
---

## Compliance Checking

### Lambda Function

```bash

Name: dev-compliance-checker
Language: Python 3.11
Memory: 128 MB (default)
Timeout: 60 seconds
Runtime: Python 3.11
Environment Variables:
└─ SNS_TOPIC_ARN: arn:aws:sns:...
Execution Role:
├─ Permissions to call EC2 API
├─ Permissions to call RDS API
└─ Permissions to publish to SNS

```
---

### EventBridge Schedule

```bash

Name: daily-infrastructure-audit
Schedule: cron(0 8 * * ? *) - 8 AM UTC daily
Target: Lambda function

When triggered:
1. Lambda runs compliance checks (security groups, RDS, networking, encryption)
2. Collects findings in structured format
3. Counts by severity (CRITICAL, HIGH, MEDIUM, INFO)
4. Publishes email to SNS topic
5. Email arrives in your inbox with full report

```
---

## Monitoring & Logging

### CloudWatch Logs

```bash

VPC Flow Logs:
└─ /aws/vpc/flowlogs/dev
Lambda Logs:
└─ /aws/lambda/dev-compliance-checker
RDS Logs:
├─ /aws/rds/instance/dev-mysql-db/error
├─ /aws/rds/instance/dev-mysql-db/general
└─ /aws/rds/instance/dev-mysql-db/slowquery

```
---

### CloudWatch Metrics

```bash

Available for monitoring:
EC2:
├─ CPU Utilization
├─ Network In/Out
└─ Disk I/O
RDS:
├─ CPU Utilization
├─ Database Connections
├─ Read/Write Latency
└─ Storage Used
ALB:
├─ Request Count
├─ Target Response Time
├─ HTTP 4xx / 5xx
└─ Active Connection Count

```
---

## Performance Characteristics

### Latency

```bash

Client to ALB: 5-20ms (depends on ISP)
ALB to Web Server: <1ms (VPC internal)
Web to App (same AZ): <1ms (VPC internal)
Web to App (cross-AZ): <5ms (within region)
App to Database (same AZ): <1ms (VPC internal)
App to Database (cross-AZ): <5ms

```
---

### Throughput

```bash

VPC Internal: No limit (no charges)
Internet Gateway: Unlimited
ALB: Can handle thousands of requests/sec
RDS: ~1000 connections default (configurable)

```
---
### Cost

```bash

VPC: Free
Subnets: Free
Route Tables: Free
Security Groups: Free
IGW: Free
ENI (network interfaces): Free
EC2: Charged hourly
RDS: Charged hourly
ALB: Charged hourly + data processing
Data Transfer: Charged per GB out
Lambda: Charged per invocation

```
---

## Disaster Recovery

### Backup & Recovery

```bash

Point-in-Time Recovery:
├─ Database can be restored to any point in 35 days
├─ Time to restore: ~5-10 minutes
└─ Data loss: Up to 5 minutes
RTO (Recovery Time Objective): <15 minutes
RPO (Recovery Point Objective): <5 minutes

```
---

### Failover Scenarios

```bash

EC2 Instance Fails:
├─ ALB health check detects failure
├─ Auto-scaling replaces instance
└─ Recovery time: ~2 minutes
RDS Primary Fails:
├─ Multi-AZ automatic failover
├─ Replica becomes primary
└─ Recovery time: <2 minutes
Entire AZ Fails:
├─ Instances in other AZ still running
├─ RDS automatic failover to other AZ
└─ Recovery time: Automatic
ALB Fails:
├─ AWS manages ALB (highly available)
├─ Automatic recovery by AWS
└─ No action needed

```
---

## Scaling Considerations

### Horizontal Scaling

```bash

More Web Servers:
├─ Auto-scaling group max size: currently 2
├─ Change web_max_size in terraform.tfvars
└─ Terraform apply to update
More App Servers:
├─ Auto-scaling group max size: currently 2
├─ Change app_max_size in terraform.tfvars
└─ Terraform apply to update
More Database:
├─ RDS Aurora auto-scales storage
├─ Manual instance upgrade: db.t3.small → db.t3.medium
└─ Requires brief downtime (Multi-AZ handles)

```
---

### Vertical Scaling

```bash

Larger EC2 Instances:
├─ Current: t3.micro (free tier)
├─ Production: t3.medium or m5.large
└─ Update: web_instance_type in terraform.tfvars
Larger Database:
├─ Current: db.t3.micro (free tier)
├─ Production: db.t3.small or db.m5.large
└─ Update: db_instance_class in terraform.tfvars

```
---

## Security Best Practices Implemented


✅ **Encryption**
- AES-256 at rest
- TLS in transit
- All credentials in Secrets Manager (not in code)

✅ **Network Isolation**
- Three-tier architecture
- Security groups (stateful firewall)
- NACLs (additional defense layer)
- Private subnets have no internet route

✅ **Access Control**
- IAM roles (not hardcoded keys)
- Least privilege policies
- Security group restrictions

✅ **Monitoring**
- VPC Flow Logs
- CloudWatch logs
- CloudTrail (optional)

✅ **Compliance**
- Automated daily scans
- CIS benchmarks checked
- Email alerts
- Audit trail

---

## Conclusion

This architecture demonstrates:

1. **Security**: Multiple layers of defense (security groups, encryption, isolation)
2. **Availability**: Multi-AZ with automatic failover
3. **Scalability**: Auto-scaling groups and ALB
4. **Compliance**: Automated daily compliance checking
5. **Monitoring**: Complete visibility with logs and metrics
6. **Cost-Efficiency**: Free tier eligible for testing

Perfect for production workloads while remaining cost-effective for development/testing.

---