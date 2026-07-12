<div align="center">

#  Three-Tier VPC + Compliance Checker

[![Made with Terraform](https://img.shields.io/badge/Made%20with-Terraform-623CE4?logo=terraform&logoColor=white&style=flat-square)](https://www.terraform.io/)
[![AWS Architecture](https://img.shields.io/badge/AWS-Multi--AZ%20Production%20Grade-FF9900?logo=amazon-aws&logoColor=white&style=flat-square)](https://aws.amazon.com/)
[![Python Lambda](https://img.shields.io/badge/Lambda-Python%203.11-3776AB?logo=python&logoColor=white&style=flat-square)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

**Production-grade three-tier VPC with automated compliance scanning, AI-powered analysis, and security hardening.**

[ Quick Start](#-quick-start) • [ Architecture](#-architecture) • [ Cost](#-cost) • [ Docs](#-documentation) • [ Learning](#-learning-outcomes)

</div>

---
##  Architecture

<img width="1536" height="1024" alt="vpc plus AI compliance checker" src="https://github.com/user-attachments/assets/bd2b8b53-5151-4da9-986a-7352f8b5fe58" />



---

##  Project Overview

A complete, enterprise-ready AWS infrastructure demonstrating **cloud security best practices** with automated compliance monitoring. Built to impress in interviews and deploy to production.

### What Makes This Special?

| Feature | Benefit |
|---------|---------|
| **3-Tier Architecture** | Network isolation + defense in depth |
| **Multi-AZ Deployment** | High availability & automatic failover |
| **Encryption Everywhere** | AES-256 at rest + TLS in transit |
| **AI Compliance Checker** | Daily scans using Claude 3 Haiku |
| **Auto-Remediation** | Critical issues fixed automatically |
| **Email Alerts** | SNS notifications with AI analysis |
| **Infrastructure-as-Code** | Terraform + Git = reproducible & version controlled |
| **CI/CD Ready** | GitHub Actions pipeline included |

---



##  Key Features

###  Security First

- ✅ **Network Isolation**: Three-tier architecture (web → app → database)
- ✅ **Encryption**: AES-256 at rest, TLS in transit
- ✅ **VPC Flow Logs**: All network traffic monitored & logged
- ✅ **Security Groups**: Restrictive by default (least privilege)
- ✅ **Multi-AZ**: Automatic failover across availability zones
- ✅ **Deletion Protection**: Prevents accidental database deletion

###  Automated Compliance

- ✅ **Daily Scans**: 50+ security checks (CIS benchmarks)
- ✅ **AI Analysis**: Claude 3 Haiku explains every finding
- ✅ **Auto-Remediation**: Critical issues fixed automatically
- ✅ **Email Alerts**: SNS notifications with recommendations
- ✅ **Audit Trail**: CloudWatch logs for compliance evidence
- ✅ **No Manual Work**: Set it and forget it

###  Production Ready

- ✅ **High Availability**: Multi-AZ with Auto Scaling Groups
- ✅ **Load Balancing**: ALB distributes traffic across instances
- ✅ **Database HA**: RDS Aurora with automatic backups
- ✅ **Monitoring**: CloudWatch metrics & logs for all resources
- ✅ **Scalability**: Horizontal & vertical scaling options
- ✅ **Cost Optimized**: Free tier eligible (t3.micro, db.t3.micro)

---

##  Quick Start

### Prerequisites

```bash
✓ AWS Account (free tier eligible)
✓ Terraform 1.5+
✓ AWS CLI v2
✓ Git
✓ Email for SNS notifications
```

### Deploy in 3 Commands

```bash
three-tier-vpc-compliance-checker/
│
├── terraform/                        # Infrastructure-as-Code
│   ├── main.tf                       # VPC, EC2, RDS, ALB, Lambda
│   ├── variables.tf                  # Input variable definitions
│   ├── outputs.tf                    # Output values after deployment
│   ├── terraform.tfvars              # Your configuration values
│   ├── user_data_web.sh              # Web server startup script
│   ├── user_data_app.sh              # App server startup script
│   └── README.md                     # Terraform guide
│
├── lambda/compliance_checker/        # Compliance scanning engine
│   ├── compliance_checker.py         # Main Lambda function
│   ├── requirements.txt              # Python dependencies
│   └── checks/
│       ├── security_groups.py        # SG compliance checks
│       ├── networking.py             # Network compliance checks
│       ├── database.py               # RDS compliance checks
│       └── encryption.py             # Encryption compliance checks
│
├── docs/                             # Documentation
│   ├── ARCHITECTURE.md               # Detailed design
│   ├── DEPLOYMENT.md                 # Deployment guide
│   ├── VPC_DESIGN.md                 # Network specification
│   ├── COMPLIANCE_RULES.md           # Security checks
│   └── INTERVIEW_GUIDE.md            # Interview prep
│
├── .github/workflows/
│   └── deploy.yml                    # GitHub Actions CI/CD
│
├── README.md                         # This file
└── .gitignore                        # Git ignore rules
three-tier-vpc-compliance-checker/
│
├── terraform/                        # Infrastructure-as-Code
│   ├── main.tf                       # VPC, EC2, RDS, ALB, Lambda
│   ├── variables.tf                  # Input variable definitions
│   ├── outputs.tf                    # Output values after deployment
│   ├── terraform.tfvars              # Your configuration values
│   ├── user_data_web.sh              # Web server startup script
│   ├── user_data_app.sh              # App server startup script
│   └── README.md                     # Terraform guide
│
├── lambda/compliance_checker/        # Compliance scanning engine
│   ├── compliance_checker.py         # Main Lambda function
│   ├── requirements.txt              # Python dependencies
│   └── checks/
│       ├── security_groups.py        # SG compliance checks
│       ├── networking.py             # Network compliance checks
│       ├── database.py               # RDS compliance checks
│       └── encryption.py             # Encryption compliance checks
│
├── docs/                             # Documentation
│   ├── ARCHITECTURE.md               # Detailed design
│   ├── DEPLOYMENT.md                 # Deployment guide
│   ├── VPC_DESIGN.md                 # Network specification
│   ├── COMPLIANCE_RULES.md           # Security checks
│   └── INTERVIEW_GUIDE.md            # Interview prep
│
├── .github/workflows/
│   └── deploy.yml                    # GitHub Actions CI/CD
│
├── README.md                         # This file
└── .gitignore                        # Git ignore rules

```

## Deployment commands


```bash
# 1. Clone and navigate
git clone https://github.com/stanleyjnrkanzara@gmail.com/three-tier-vpc-compliance-checker.git
cd three-tier-vpc-compliance-checker/terraform

# 2. Review the plan
terraform init
terraform plan -var="email_address=your@email.com"

# 3. Deploy (10-15 minutes)
terraform apply -var="email_address=your@email.com"
```

**Then:**
1. ✅ Confirm SNS email subscription
2. ✅ Test ALB DNS in browser
3. ✅ Wait for compliance scan (8 AM UTC tomorrow)
4. ✅ Check email for report

---

##  Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Cloud** | AWS VPC, EC2, RDS, Lambda, SNS, CloudWatch | Infrastructure |
| **IaC** | Terraform 1.5+ | Code-defined infrastructure |
| **Compute** | EC2 (t3.micro for testing) | Web & app servers |
| **Database** | RDS Aurora MySQL | Encrypted, Multi-AZ database |
| **Load Balancer** | AWS ALB | Distribute traffic across AZs |
| **Compliance** | Lambda + Python 3.11 | Automated scanning |
| **AI Analysis** | Amazon Bedrock (Claude 3 Haiku) | Explain findings |
| **Alerts** | SNS + Email | Daily notifications |
| **CI/CD** | GitHub Actions | Automated testing & deployment |
| **Monitoring** | CloudWatch + VPC Flow Logs | Complete visibility |

---

##  Deployment Details

### Resource Breakdown

✓ VPC + Internet Gateway
✓ 6 Subnets (2 public, 2 app, 2 database) across 2 AZs
✓ 3 Route Tables (public, private app, private database)
✓ 3 Security Groups (defense in depth)
✓ 1 Application Load Balancer
✓ 2 Launch Templates (web, app)
✓ 2 Auto Scaling Groups (min 1, max 2)
✓ 1 RDS Aurora MySQL database (Multi-AZ)
✓ 1 Lambda function (compliance checker)
✓ 1 SNS Topic + Email subscription
✓ VPC Flow Logs to CloudWatch
✓ Total: 32 AWS resources



### Deployment Time

| Phase | Duration |
|-------|----------|
| Terraform Init | < 1 minute |
| Terraform Plan | 2-3 minutes |
| Terraform Apply | 10-15 minutes |
| SNS Confirmation | 1-5 minutes |
| First Compliance Scan | Automated (8 AM UTC) |
| **Total** | **15-20 minutes** |

---

##  Cost Analysis

### Development/Testing (Lite Version)

| Resource | Hourly Rate | 24-Hour Cost |
|----------|------------|--------------|
| ALB | $0.0225/hr | $0.54 |
| Data Processing | ~$0.01/hr | $0.24 |
| Lambda | Pay-per-invocation | ~$0.01 |
| SNS | Pay-per-email | ~$0.02 |
| **Free Resources** | EC2, RDS, VPC | $0.00 |
| **Total 24h** | | **~$1.00** |

### Production (Full Resources)

| Service | Monthly Cost |
|---------|--------------|
| EC2 (t3.medium × 4) | $60 |
| RDS Aurora (t3.small) | $80 |
| NAT Gateways (× 2) | $65 |
| ALB | $20 |
| Data Transfer | $5 |
| Lambda + Monitoring | $1 |
| **Total** | **~$181/month** |

** First 12 months eligible for AWS Free Tier = $0 cost!**

---

##  Documentation

| Document | Purpose |
|----------|---------|
| **[ARCHITECTURE.md](./docs/ARCHITECTURE.md)** | Detailed VPC design & networking |
| **[DEPLOYMENT.md](./docs/DEPLOYMENT.md)** | Step-by-step deployment guide |
| **[VPC_DESIGN.md](./docs/VPC_DESIGN.md)** | Network topology & IP addressing |
| **[COMPLIANCE_RULES.md](./docs/COMPLIANCE_RULES.md)** | 50+ security checks explained |
| **[INTERVIEW_GUIDE.md](./docs/INTERVIEW_GUIDE.md)** | Talking points for recruiters |
| **[terraform/README.md](./terraform/README.md)** | Terraform-specific guide |

---

##  Project Structure

three-tier-vpc-compliance-checker/
│
├── terraform/                        # Infrastructure-as-Code
│   ├── main.tf                       # VPC, EC2, RDS, ALB, Lambda
│   ├── variables.tf                  # Input variable definitions
│   ├── outputs.tf                    # Output values after deployment
│   ├── terraform.tfvars              # Your configuration values
│   ├── user_data_web.sh              # Web server startup script
│   ├── user_data_app.sh              # App server startup script
│   └── README.md                     # Terraform guide
│
├── lambda/compliance_checker/        # Compliance scanning engine
│   ├── compliance_checker.py         # Main Lambda function
│   ├── requirements.txt              # Python dependencies
│   └── checks/
│       ├── security_groups.py        # SG compliance checks
│       ├── networking.py             # Network compliance checks
│       ├── database.py               # RDS compliance checks
│       └── encryption.py             # Encryption compliance checks
│
├── docs/                             # Documentation
│   ├── ARCHITECTURE.md               # Detailed design
│   ├── DEPLOYMENT.md                 # Deployment guide
│   ├── VPC_DESIGN.md                 # Network specification
│   ├── COMPLIANCE_RULES.md           # Security checks
│   └── INTERVIEW_GUIDE.md            # Interview prep
│
├── .github/workflows/
│   └── deploy.yml                    # GitHub Actions CI/CD
│
├── README.md                         # This file
└── .gitignore                        # Git ignore rules
---

##  Learning Outcomes

After building this project I learnt mastery in:

| Topic | What I Learnt in the Project |
|-------|-------------------|
| **AWS VPC** | 3-tier architecture, subnets, routing, security |
| **EC2** | Launch templates, auto-scaling, security groups |
| **RDS** | Aurora MySQL, encryption, backups, Multi-AZ |
| **Load Balancing** | ALB, target groups, health checks |
| **Lambda** | Event-driven functions, environment variables |
| **Compliance** | Security scanning, remediation, audit trails |
| **Terraform** | Variables, outputs, state management |
| **GitHub Actions** | CI/CD pipelines, automated testing |
| **AWS Well-Architected** | Security, reliability, performance, cost |
| **Interview Skills** | How to talk about cloud architecture |

---

---

##  Example Compliance Report

When the Lambda function runs, you'll receive an email like:

╔════════════════════════════════════════════════════════════╗
║          VPC COMPLIANCE AUDIT REPORT                       ║
╚════════════════════════════════════════════════════════════╝
Generated: 2024-07-11 08:00:00 UTC
════════════════════════════════════════════════════════════
📊 VIOLATION SUMMARY
════════════════════════════════════════════════════════════
🚨 CRITICAL Violations: 0
⚠️  HIGH Violations: 0
⚡ MEDIUM Violations: 0
✅ All systems compliant!
════════════════════════════════════════════════════════════
Next scan: Tomorrow at 8:00 AM UTC


---

##  Interview Talking Points

### The Hook

> "I architected a production three-tier VPC that demonstrates enterprise cloud security patterns. Then I automated compliance monitoring with AI-powered analysis that catches misconfigurations before they become security incidents."

### Key Differentiators

1. **3-Tier Architecture**: Shows understanding of network isolation
2. **Infrastructure-as-Code**: Reproducible & version controlled
3. **Compliance Automation**: Proactive vs. reactive security
4. **AI Integration**: Using Claude for meaningful analysis
5. **Multi-AZ Design**: High availability thinking
6. **Cost Optimization**: Free tier eligible

See [INTERVIEW_GUIDE.md](./docs/INTERVIEW_GUIDE.md) for complete talking points.

---

##  Next Steps

1. **Clone the repo**
```bash
   git clone https://github.com/YOUR-USERNAME/three-tier-vpc-compliance-checker.git
   cd three-tier-vpc-compliance-checker
```

2. **Review documentation**
   - Read [DEPLOYMENT.md](./docs/DEPLOYMENT.md) for detailed steps
   - Check [ARCHITECTURE.md](./docs/ARCHITECTURE.md) for design details

3. **Deploy infrastructure**
```bash
   cd terraform
   terraform init
   terraform plan -var="email_address=your@email.com"
   terraform apply -var="email_address=your@email.com"
```

4. **Document & share**
   - Take screenshots
   - Update your portfolio
   - Post on LinkedIn
   - Use in interviews

---

##  Support

### Common Questions

**Q: How much will this cost?**
A: ~$1 for 24-hour testing using free-tier resources. $0 if within AWS free tier.

**Q: How long to deploy?**
A: 15-20 minutes total (mostly Terraform provisioning).

**Q: Can I run this in production?**
A: Yes! Update `terraform.tfvars` to use larger instance types (t3.medium, db.t3.small).

**Q: What if deployment fails?**
A: Run `terraform destroy` to clean up, then troubleshoot. Check [DEPLOYMENT.md](./docs/DEPLOYMENT.md) FAQ section.

**Q: How do I modify the infrastructure?**
A: Edit `terraform.tfvars` or `.tf` files, then run `terraform apply` again.

---

##  Why This Project Stands Out

| What | Why It Matters |
|------|----------------|
| **Production-Grade** | Not a toy project - actual best practices |
| **Security-First** | Encryption, isolation, compliance automation |
| **AI-Powered** | Uses Claude for analysis (not just reporting) |
| **Multi-AZ** | Shows HA thinking from day one |
| **Well-Documented** | Interview-ready explanations |
| **Infrastructure-as-Code** | Reproducible & version controlled |
| **Cost Conscious** | Free tier eligible for testing |
| **Complete** | From networking to compliance |

---

##  License

MIT License - Feel free to use and modify for your own projects.

---

##  Acknowledgments

- AWS Well-Architected Framework
- CIS AWS Foundations Benchmark
- Terraform Best Practices
- Claude 3 Haiku (AI analysis)

---

<div align="center">

### ⭐ If this helped you, star the repository!

**Ready to build production-grade infrastructure?**

[ Get Started](#-quick-start) • [ Read Docs](#-documentation) • [ LinkedIn] https://www.linkedin.com/in/stanley-jnr-kanzara-0081133a8?utm_source=share_via&utm_content=profile&utm_medium=member_android
  • [🐙 GitHub](https://github.com/stanleyjnrkanzara-wq)

**Built to deploy to production.** 🎯

</div>
