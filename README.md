# three-tier-vpc-compliance-checker
Production-grade three-tier VPC with automated compliance scanning, encryption, and CIS benchmark validation. Email alerts + auto-remediation for security violations.

#  Three-Tier VPC + Compliance Checker

A production-grade AWS VPC architecture with automated compliance scanning, security hardening, and CIS benchmark validation. Built with Terraform + Python Lambda + Claude AI.

##  What This Does

### Three-Tier VPC Architecture
- **Public Tier (Web Layer)**: Application Load Balancer + Auto-scaled EC2s
- **Private Tier (App Layer)**: Application servers (no internet access)
- **Private Tier (Database Layer)**: RDS Aurora MySQL (encrypted, Multi-AZ)
- **Network Security**: Security Groups, NACLs, VPC Flow Logs
- **Compliance**: Encryption everywhere, proper tagging, least-privilege access

### Compliance Checker
- **Continuous Scanning**: Runs daily (configurable)
- **50+ Security Checks**: CIS benchmarks, encryption, logging, access control
- **AI-Powered Reports**: Claude explains every finding
- **Auto-Remediation**: Fixes critical violations automatically
- **Email Alerts**: SNS notifications with actionable insights
- **Audit Trail**: CloudWatch logs for all scans

##  Quick Stats

- **Deployment Time**: 30 minutes (Terraform)
- **Monthly Cost**: ~$181 (or $0 with free tier for lite version)
- **Availability**: Multi-AZ (highly available)
- **Compliance**: CIS AWS Foundations Benchmark compliant
- **Security**: Encryption at rest + in transit

##  Quick Start

### Prerequisites
- AWS Account with free tier
- Terraform installed
- AWS CLI configured
- Git installed

### Deployment

```bash
git clone https://github.com/stanleyjnrkanzara-wq/three-tier-vpc-compliance-checker.git
cd three-tier-vpc-compliance-checker/terraform
terraform init
terraform plan -var="email_address=stanleyjnranzara@gmail.com"
terraform apply -var="email_address=stanleyjnrkanzara@gmail.com"


Then confirm the SNS email subscription.

## 📁 Project Structure

three-tier-vpc-compliance-checker/
├── terraform/ # Infrastructure-as-Code
│ ├── main.tf # VPC, EC2, RDS, Lambda
│ ├── variables.tf # Input variables
│ ├── outputs.tf # Output values
│ ├── terraform.tfvars # Configuration values
│ ├── user_data_web.sh # Web server setup
│ ├── user_data_app.sh # App server setup
│ └── README.md # Terraform guide
│
├── lambda/ # Compliance Checker
│ └── compliance_checker/
│ ├── compliance_checker.py
│ ├── requirements.txt
│ └── checks/
│ ├── security_groups.py
│ ├── networking.py
│ ├── database.py
│ └── encryption.py
│
├── docs/ # Documentation
│ ├── ARCHITECTURE.md
│ ├── VPC_DESIGN.md
│ ├── COMPLIANCE_RULES.md
│ ├── DEPLOYMENT.md
│ ├── INTERVIEW_GUIDE.md
│ └── CI_CD.md
│
├── .github/workflows/
│ └── deploy.yml # GitHub Actions CI/CD
│
└── README.md # This file


##  Tech Stack

- **Cloud**: AWS VPC, EC2, RDS, Lambda, Bedrock
- **Infrastructure-as-Code**: Terraform
- **Languages**: Python 3.11, HCL (Terraform)
- **CI/CD**: GitHub Actions
- **AI**: Amazon Bedrock (Claude 3 Haiku)
- **Monitoring**: CloudWatch, VPC Flow Logs

##  Documentation

- [ARCHITECTURE.md](./docs/ARCHITECTURE.md) - Detailed VPC design
- [DEPLOYMENT.md](./docs/DEPLOYMENT.md) - Step-by-step deployment
- [VPC_DESIGN.md](./docs/VPC_DESIGN.md) - Network topology
- [COMPLIANCE_RULES.md](./docs/COMPLIANCE_RULES.md) - 50+ security checks
- [INTERVIEW_GUIDE.md](./docs/INTERVIEW_GUIDE.md) - Talking points for recruiters

##  Cost

### Production (Full Resources)
- EC2 t3.medium × 4: $60/month
- RDS Aurora t3.small: $80/month
- NAT Gateways × 2: $65/month
- ALB: $20/month
- **Total: ~$181/month**

### Development (Free Tier)
- EC2 t3.micro × 2-4: Free (free tier)
- RDS Aurora t3.micro: Free (free tier)
- No NAT Gateways: $0
- ALB: ~$0.50/day for testing
- **Total: ~$1-2 for 24-hour deployment**

##  Security Features

✅ **Network Isolation**: Three-tier separation (defense in depth)
✅ **Encryption**: AES-256 at rest + TLS in transit
✅ **Multi-AZ**: Automatic failover and high availability
✅ **VPC Flow Logs**: Complete network traffic visibility
✅ **Automated Scanning**: Daily compliance checks
✅ **Auto-Remediation**: Critical issues fixed automatically

##  Learning Outcomes

After building this project, you'll understand:

- Advanced VPC architecture (3-tier pattern)
- Network security (security groups, NACLs, routing)
- High availability (Multi-AZ, Auto Scaling, ALB)
- Database design (RDS Aurora, encryption, backups)
- Infrastructure-as-Code (Terraform, modules, state)
- Compliance automation (scanning, remediation)
- Lambda integration with AWS services
- CI/CD pipelines with GitHub Actions

##  Share on LinkedIn
