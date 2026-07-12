#  Step-by-Step Deployment Guide

Complete hand-holding guide to deploy the three-tier VPC infrastructure.

## Prerequisites Checklist

Before you start, verify you have:

- [ ] AWS Account with free tier eligibility
- [ ] AWS CLI installed and configured
- [ ] Terraform 1.5+ installed
- [ ] Git installed
- [ ] Email address for SNS notifications
- [ ] Text editor (VS Code recommended)
- [ ] Internet connection

### Verify Prerequisites

```bash
# Check AWS CLI
aws --version
aws sts get-caller-identity

# Check Terraform
terraform --version

# Check Git
git --version
```

All should return version numbers (no errors).

---

## Phase 1: Prepare Your Workstation

### Step 1.1: Configure AWS CLI

If not already configured:

```bash
aws configure
```

Enter:
- AWS Access Key ID: (your key)
- AWS Secret Access Key: (your secret)
- Default region: us-east-1
- Default output format: json

Verify:

```bash
aws sts get-caller-identity
```

Should show your AWS Account ID.

### Step 1.2: Clone the Repository

```bash
cd ~/Documents  # Or where you keep projects
git clone https://github.com/YOUR-USERNAME/three-tier-vpc-compliance-checker.git
cd three-tier-vpc-compliance-checker
```

Verify you're in the right folder:

```bash
pwd
ls -la
```

Should show: README.md, terraform/, lambda/, docs/, etc.

---

## Phase 2: Configure Terraform

### Step 2.1: Review terraform.tfvars

Open the file:

```bash
code terraform/terraform.tfvars
```

(Or use your text editor)

**CRITICAL**: Update these values:

```hcl
# Change BOTH of these
email_address = "stanleyjnkanzara@gmail.com"  # ← YOUR email
db_password = "MyPassword2024!@#456"          # ← STRONG password (you'll need this!)
```

Save the file.

### Step 2.2: Verify File Structure

Make sure these files exist:

```bash
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── user_data_web.sh
├── user_data_app.sh
└── README.md
```

Verify:

```bash
ls -la terraform/
```

All files should be present.

---

## Phase 3: Initialize Terraform

### Step 3.1: Navigate to Terraform Directory

```bash
cd terraform
```

Verify:

```bash
pwd
```

Should end with `/three-tier-vpc-compliance-checker/terraform`

### Step 3.2: Initialize Terraform

```bash
terraform init
```

This downloads AWS provider and initializes Terraform.

**Expected output:**

Success! The configuration is valid.

If you get errors, stop and troubleshoot before continuing.

### Step 4.2: Run Terraform Plan

```bash
terraform plan -var="email_address=stanleyjnkanzara@gmail.com"
```

Replace with YOUR email address.

This will:
1. Query AWS for existing resources
2. Compare with your Terraform code
3. Show what will be created (without creating it)

**This takes 30-60 seconds.**

**Expected output:**
...
Plan: 32 to add, 0 to change, 0 to destroy.

### Step 4.3: Review Plan Output

Scroll through and look for:

✅ **VPC**: `aws_vpc.main will be created`
✅ **Subnets**: `aws_subnet.public_1`, `aws_subnet.public_2`, etc.
✅ **Security Groups**: 3 security groups will be created
✅ **EC2 Resources**: Launch templates and Auto Scaling Groups
✅ **RDS Database**: MySQL database will be created
✅ **ALB**: Application Load Balancer will be created
✅ **Lambda**: Compliance checker will be created
✅ **SNS**: Topic and email subscription will be created

**Red Error Messages?** Stop and fix before applying. Common issues:
Error: "No VPC found"
→ Wait 5 minutes and try again (AWS rate limiting)
Error: "Invalid region"
→ Verify aws_region = "us-east-1" in terraform.tfvars
Error: Syntax errors
→ Check terraform/main.tf for typos

### Step 4.4: Confirm You're Ready

Before applying, answer these questions:

- [ ] Does the plan show 32 resources to add?
- [ ] No errors in the plan output?
- [ ] Email address is correct in the plan?
- [ ] You have a STRONG database password saved?
- [ ] You're in the terraform/ directory?

If all YES, proceed to Phase 5.

---

## Phase 5: Deploy Infrastructure

### Step 5.1: Apply Terraform

```bash
terraform apply -var="email_address=stanleyjnkanzara@gmail.com"
```

Replace with YOUR email address.

**This creates all 32 resources.**

**This takes 10-15 minutes. Go get coffee! ☕**

Watch the output as resources are created:
aws_vpc.main: Creating...
aws_vpc.main: Creation complete after 3s [id=vpc-0123456789abcdef]
aws_internet_gateway.main: Creating...
aws_internet_gateway.main: Creation complete after 2s [id=igw-0123456789abcdef]
...

### Step 5.2: Wait for Completion

When done, you'll see:
Apply complete! Resources: 32 added.

Followed by the outputs:
Outputs:
alb_dns_name = "app-123456789.us-east-1.elb.amazonaws.com"
deployment_summary = {
"alb_dns" = "app-123456789.us-east-1.elb.amazonaws.com"
"app_asg_min" = 1
"app_asg_max" = 2
"rds_endpoint" = "dev-mysql-db.c1234567890.us-east-1.rds.amazonaws.com"
"vpc_id" = "vpc-0123456789abcdef"
...
}

**SAVE THIS OUTPUT!** You'll need the ALB DNS name.

### Step 5.3: Verify Deployment

Check that resources were created:

```bash
# Get ALB DNS
terraform output alb_dns_name

# Get all outputs
terraform output deployment_summary
```

Example:

```bash
$ terraform output alb_dns_name
app-123456789.us-east-1.elb.amazonaws.com
```

---

## Phase 6: Confirm SNS Email Subscription

### Step 6.1: Check Your Email

Go to the email address you entered in terraform.tfvars.

**Look for an email from AWS SNS:**
From: aws@sns.amazonaws.com
Subject: AWS Notification - Subscription Confirmation

**Screenshot your confirmation email** (for documentation).

### Step 6.2: Click Confirmation Link

The email contains:
To confirm this subscription, click or visit the link below:
https://sns.amazonaws.com/confirm-subscription/us-east-1/...

**Click the link immediately!**

You'll see a page saying:
Subscription confirmed!

### Step 6.3: Verify in AWS Console

Optional verification:

```bash
# AWS Console
Go to SNS → Topics → dev-compliance-alerts → Subscriptions
Status should show: Confirmed
```

✅ **If you see "Confirmed", you're all set!**

❌ **If you see "PendingConfirmation", the emails won't arrive. Resend confirmation link.**

---

## Phase 7: Test the Infrastructure

### Step 7.1: Test ALB (Web Server)

In your browser, go to:
http://app-123456789.us-east-1.elb.amazonaws.com

(Replace with YOUR ALB DNS name from terraform output)

**Expected response:**
✅ Web Tier is Running!
Environment: dev
Instance ID: i-0123456789abcdef
Availability Zone: us-east-1a
Region: us-east-1

**Screenshot this page** (for documentation).

### Step 7.2: Check EC2 Instances

In AWS Console:
EC2 → Instances

You should see:

- 1-2 instances with name containing "web" (public tier)
- 1-2 instances with name containing "app" (private tier)

Status should be: **Running** ✅

**Screenshot this page.**

### Step 7.3: Check RDS Database

In AWS Console:
RDS → Databases → dev-mysql-db

Status should be: **Available** ✅

Details should show:
- Engine: MySQL 8.0.35
- Instance class: db.t3.micro
- Multi-AZ: true
- Publicly accessible: false
- Encryption: enabled

**Screenshot this page.**

### Step 7.4: Check Load Balancer

In AWS Console:
EC2 → Load Balancers → (dev-alb)

Status should be: **Active** ✅

Target Groups:
- 1-2 targets in HEALTHY state

**Screenshot this page.**

---

## Phase 8: Trigger Compliance Scan

### Step 8.1: Manual Lambda Invocation

The compliance checker normally runs at 8 AM UTC. To test immediately:

```bash
cd terraform
aws lambda invoke \
  --function-name dev-compliance-checker \
  --region us-east-1 \
  response.json

cat response.json
```

This manually triggers the Lambda function.

### Step 8.2: Wait for Email

Check your email for the compliance report.

**Within 1-2 minutes, you should receive:**
From: AWS Notifications
Subject: VPC Compliance Report - YYYY-MM-DD

**Expected body:**

```bash

╔════════════════════════════════════════════════════════════╗
║          VPC COMPLIANCE AUDIT REPORT                       ║
╚════════════════════════════════════════════════════════════╝
Generated: YYYY-MM-DD HH:MM:SS UTC
════════════════════════════════════════════════════════════
📊 VIOLATION SUMMARY
════════════════════════════════════════════════════════════
🚨 CRITICAL Violations: 0
⚠️  HIGH Violations: 0
⚡ MEDIUM Violations: 0
... more details ...

```

---

## Phase 9: Document Your Deployment

Create a new file:

```bash
cd ../docs
touch DEPLOYMENT_RESULTS.md
```


### Key Outputs
- VPC ID: vpc-...
- ALB DNS: app-...
- RDS Endpoint: dev-mysql-db...
- Deployment Time: 15 minutes
- Cost: $0.50
```

---

## Phase 10: Cleanup (Optional)

When you're done testing and have taken screenshots:

### Step 10.1: Destroy Infrastructure

```bash
cd terraform
terraform destroy -var="email_address=stanleyjnkanzara@gmail.com"
```

Type `yes` when prompted.

**This deletes everything:**
- VPC
- EC2 instances
- RDS database
- ALB
- Lambda
- SNS
- CloudWatch logs

**This takes 5-10 minutes.**

### Step 10.2: Verify Cleanup

```bash
# Should show empty state
terraform state list
```

### Step 10.3: Commit & Push

```bash
cd ..
git add .
git commit -m "docs: add deployment screenshots and results"
git push origin main
```

---

## Troubleshooting

### Issue: "Access Denied" Error

**Problem:** AWS credentials not configured
**Solution:**
```bash
aws configure
# Enter your Access Key ID and Secret Access Key
```

### Issue: "No VPC Found" Error

**Problem:** VPC still creating or AWS rate limiting
**Solution:** Wait 5 minutes and run `terraform apply` again

### Issue: ALB not responding (timeout)

**Problem:** EC2 instances still starting up
**Solution:** Wait 3-5 minutes for instances to boot and install software

### Issue: Email not received from SNS

**Problem:** Subscription not confirmed
**Solution:**
1. Check spam folder
2. Resend confirmation in SNS console
3. Wait 5 minutes

### Issue: "Terraform state lock" Error

**Problem:** Another deployment in progress
**Solution:** Wait 5 minutes or manually unlock:
```bash
terraform force-unlock <LOCK-ID>
```

### Issue: Deployment costs more than expected

**Problem:** Using production instance types
**Solution:** 
1. Verify terraform.tfvars uses t3.micro and db.t3.micro
2. Destroy: `terraform destroy`
3. Delete in AWS Console if resources remain
4. Redeploy with correct settings

---

## Cost Tracking

### Monitor Costs in AWS Console
AWS Console → Billing → Billing Dashboard

Check:
- Estimated charges for today
- Service breakdown
- Cost by resource

### Expected Costs

| Service | Duration | Cost |
|---------|----------|------|
| ALB | 24 hours | $0.50 |
| Data Processing | 24 hours | $0.24 |
| EC2 (free tier) | 24 hours | $0.00 |
| RDS (free tier) | 24 hours | $0.00 |
| Lambda | 1 invocation | $0.00 |
| **Total** | | **~$1.00** |

---

## Next Steps

1. ✅ Take screenshots of deployment
2. ✅ Document in DEPLOYMENT_RESULTS.md
3. ✅ Update your GitHub repository
4. ✅ Post on LinkedIn
5. ✅ Use in interviews
6. ✅ Optional: Scale to production

---

## FAQ

**Q: Can I deploy this in a different region?**
A: Yes, change `aws_region = "us-east-1"` to any region in terraform.tfvars

**Q: Can I increase the database size?**
A: Yes, change `db_allocated_storage = 100` in terraform.tfvars (in GB)

**Q: Can I add more EC2 instances?**
A: Yes, change `web_max_size = 2` and `app_max_size = 2` in terraform.tfvars

**Q: Can I run this in production?**
A: Yes! Change instance types to t3.medium or larger, update RDS to db.t3.small

**Q: How do I update the infrastructure?**
A: Edit terraform.tfvars or .tf files, then run `terraform apply`

**Q: How do I delete just one resource?**
A: Use `terraform destroy -target=aws_db_instance.main` (careful!)

---
