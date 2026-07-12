# 🔐 VPC Compliance Rules & Checks

The automated compliance checker scans for 50+ security best practices.

## Security Group Checks

### 1. No Open SSH (Port 22)
- **Severity**: CRITICAL
- **Rule**: SSH should NOT be open to 0.0.0.0/0
- **Why**: Enables brute-force attacks, credential theft
- **Remediation**: Restrict to specific IP ranges or use AWS Systems Manager
- **Auto-Fix**: Yes - restricts to your IP

### 2. No Open RDP (Port 3389)
- **Severity**: CRITICAL
- **Rule**: RDP should NOT be open to 0.0.0.0/0
- **Why**: Remote desktop access from internet is high-risk
- **Remediation**: Use VPN or bastion host
- **Auto-Fix**: Yes

### 3. Database Ports Not Exposed
- **Severity**: CRITICAL
- **Rule**: Ports 3306, 5432, 1433 not open to 0.0.0.0/0
- **Why**: Direct database access = instant compromise
- **Remediation**: Restrict to application tier security group
- **Auto-Fix**: Yes

### 4. Principle of Least Privilege
- **Severity**: HIGH
- **Rule**: No security group allows all traffic (protocol -1)
- **Why**: Overly permissive = large attack surface
- **Remediation**: Restrict to specific ports/protocols needed
- **Auto-Fix**: Yes

## Networking Checks

### 5. VPC Flow Logs Enabled
- **Severity**: HIGH
- **Rule**: All VPCs must have Flow Logs enabled
- **Why**: Network visibility essential for incident response
- **Remediation**: Enable CloudWatch Flow Logs
- **Auto-Fix**: Yes - automatically enabled by Terraform

### 6. Internet Gateway Configured
- **Severity**: MEDIUM
- **Rule**: VPC has IGW if public subnets exist
- **Why**: Without IGW, can't reach internet
- **Remediation**: Attach IGW to VPC
- **Auto-Fix**: Yes - automatically created

### 7. Route Tables Properly Configured
- **Severity**: MEDIUM
- **Rule**: Routes should have clear destinations
- **Why**: Misconfigured routes cause traffic drops
- **Remediation**: Verify each route table has expected routes
- **Auto-Fix**: No - manual review needed

## Database Checks

### 8. RDS Multi-AZ Enabled
- **Severity**: HIGH
- **Rule**: Production RDS must have Multi-AZ
- **Why**: Automatic failover = high availability
- **Remediation**: Enable Multi-AZ (requires ~2-5 min downtime)
- **Auto-Fix**: Yes - automatically enabled by Terraform

### 9. RDS Automated Backups
- **Severity**: HIGH
- **Rule**: Backup retention ≥ 7 days (recommend 35+)
- **Why**: Disaster recovery requires recent backups
- **Remediation**: Increase backup_retention_days to 35
- **Auto-Fix**: Yes - automatically set to 35 days

### 10. RDS NOT Publicly Accessible
- **Severity**: CRITICAL
- **Rule**: publicly_accessible must be false
- **Why**: Public access = anyone can try to hack
- **Remediation**: Set publicly_accessible = false
- **Auto-Fix**: Yes - automatically set in Terraform

### 11. RDS Deletion Protection
- **Severity**: MEDIUM
- **Rule**: Production RDS must have deletion protection
- **Why**: Prevents accidental "whoops I deleted production" moments
- **Remediation**: Enable deletion_protection
- **Auto-Fix**: Yes - automatically enabled by Terraform

### 12. RDS CloudWatch Logs Export
- **Severity**: MEDIUM
- **Rule**: RDS should export error, general, slowquery logs
- **Why**: Log analysis helps troubleshoot and detect issues
- **Remediation**: Enable CloudWatch logs export
- **Auto-Fix**: Manual (requires RDS restart)

## Encryption Checks

### 13. RDS Storage Encryption
- **Severity**: CRITICAL
- **Rule**: RDS storage MUST be encrypted
- **Why**: Required for HIPAA, PCI-DSS, SOC 2 compliance
- **Remediation**: Enable storage encryption
- **Auto-Fix**: Yes - automatically enabled by Terraform

### 14. RDS In-Transit Encryption
- **Severity**: HIGH
- **Rule**: Connection must use SSL/TLS (require_secure_transport=1)
- **Why**: Prevents credentials from being transmitted in clear text
- **Remediation**: Set require_secure_transport=1 in parameter group
- **Auto-Fix**: Yes - automatically set by Terraform

### 15. EBS Volume Encryption
- **Severity**: HIGH
- **Rule**: All EBS volumes must be encrypted
- **Why**: Protects data at rest from unauthorized access
- **Remediation**: Enable default EBS encryption
- **Auto-Fix**: Yes - automatically enabled by Terraform

### 16. KMS Key Rotation
- **Severity**: MEDIUM
- **Rule**: KMS keys used for encryption should have auto-rotation
- **Why**: Limits exposure if key is compromised
- **Remediation**: Enable automatic key rotation
- **Auto-Fix**: Manual - set enable_key_rotation = true

## IAM & Access Checks

### 17. EC2 IAM Instance Profiles
- **Severity**: HIGH
- **Rule**: EC2 instances must use IAM roles (not access keys)
- **Why**: Temporary credentials auto-rotated, more secure
- **Remediation**: Attach IAM role via instance profile
- **Auto-Fix**: Yes - automatically done by Terraform

### 18. No Overly Permissive IAM Policies
- **Severity**: HIGH
- **Rule**: IAM policies should NOT allow "*:*" (all actions)
- **Why**: Least privilege principle = minimize blast radius
- **Remediation**: Scope policies to specific actions/resources
- **Auto-Fix**: Manual review needed

## Monitoring & Logging

### 19. CloudTrail Enabled
- **Severity**: MEDIUM
- **Rule**: CloudTrail should log all API calls
- **Why**: Audit trail needed for compliance
- **Remediation**: Enable CloudTrail at account level
- **Auto-Fix**: Manual (account-level setting)

### 20. CloudWatch Alarms
- **Severity**: MEDIUM
- **Rule**: Key metrics should have alarms
- **Why**: Alerts enable rapid response
- **Remediation**: Create alarms for CPU, network, RDS metrics
- **Auto-Fix**: Manual - can be added to Terraform

## Tagging & Organization

### 21. Resource Tagging
- **Severity**: LOW
- **Rule**: All resources should have standard tags
- **Why**: Cost allocation, resource discovery, automation
- **Remediation**: Apply tags: Environment, Owner, CostCenter
- **Auto-Fix**: Yes - automatically applied by Terraform

### 22. Name Tags
- **Severity**: LOW
- **Rule**: All resources must have Name tag
- **Why**: Improves resource discoverability
- **Remediation**: Add Name tags to all resources
- **Auto-Fix**: Yes - automatically applied

## Compliance Scoring

### How Scoring Works

Total Checks = 50+
Pass = Check passes OR auto-fixed ✅
Fail = Check fails AND manual intervention needed ❌
Warn = Check passes but could be better optimized ⚠️
Score = (Passed Checks / Total Checks) × 100
Grade:
A (90-100%): Excellent compliance
B (80-89%): Good compliance
C (70-79%): Fair compliance
D (60-69%): Poor compliance
F (<60%): Critical gaps - immediate action needed

## Automated Remediation

### The compliance checker can automatically fix:

### CRITICAL Violations (Auto-Remediated)

❌ **Publicly accessible RDS**

→ Restricted to private access (requires failover)
Time: ~2 minutes
Automated: Yes

❌ **Open SSH/RDP to 0.0.0.0/0**
→ Restricted to corporate VPN CIDR
Time: Instant
Automated: Yes

❌ **Unencrypted EBS volume**
→ Encrypted (requires snapshot + new volume)
Time: ~10 minutes
Automated: Manual

❌ Unencrypted RDS Storage
→ Encryption enabled (requires new DB instance)
Time: ~15 minutes
Automated: Manual - must recreate

HIGH Violations (Can Auto-Remediate)

⚠️ No Multi-AZ
→ Enable Multi-AZ (requires failover)
Time: ~5 minutes
Automated: Yes - with brief downtime

⚠️ Low backup retention
→ Increase to 35 days (instant)
Time: Instant
Automated: Yes

⚠️ Missing VPC Flow Logs
→ Enable CloudWatch Flow Logs (instant)
Time: Instant
Automated: Yes

## MEDIUM/LOW Violations (Manual Review)

Tagging issues
Naming conventions
IAM policy review
CloudWatch alarms
Deletion protection

## Manual Review Process

### For violations that can't auto-fix:

```bash
1. Receive Email
   └─ Compliance report with all findings

2. Read & Understand
   ├─ What was found?
   ├─ Why is it a problem?
   ├─ What's the severity?
   └─ What's the impact?

3. Plan Remediation
   ├─ Is downtime acceptable?
   ├─ Do we need to change code?
   ├─ Do we need new AWS configuration?
   └─ What's the timeline?

4. Execute Fix
   ├─ Update terraform.tfvars
   ├─ Run terraform plan
   ├─ Review changes
   └─ Run terraform apply

5. Verify Fix
   ├─ Check AWS console
   ├─ Next scan confirms issue is fixed
   └─ Add to documentation

6. Update Records
   ├─ Commit changes to Git
   ├─ Document what was fixed
   └─ Track time spent

```
---

## Exception Process

## For compliance violations that CANNOT be fixed:

### Document the Exception

Why can't it be fixed?
Business justification
Risk level accepted
Timeline for resolution


## Get Approval

Review by security team
Document approval
Set review date


## Track

Add to exceptions list
Schedule follow-up review
Re-test on schedule



## Real-World Example

## Scenario: Database is Publicly Accessible
## Email Alert:

🚨 CRITICAL: Public Database
Database dev-mysql-db is publicly accessible!
This is a severe security risk.
Risk: Anyone on internet can try to breach your database
Fix: Set publicly_accessible = false
Timeline: Update + 2 minute failover
Your Action:
bash# Edit terraform/terraform.tfvars

# Find: dev-mysql-db or RDS config
# Change: publicly_accessible = true → false
# Run:

```bash
cd terraform
terraform plan
terraform apply

```

# Result:
✅ Next compliance scan: Issue fixed!
✅ Database now only accessible from app tier
✅ Alert email confirms compliance restored

# Performance Impact

The compliance checker is lightweight:
Runtime: <30 seconds
Concurrency: Runs in single Lambda
Memory: 128 MB
Cost: <$0.01 per scan
Impact on infrastructure: None (read-only queries)

## Limitations

# The compliance checker checks:

✅ AWS API responses (what AWS knows)
❌ Application-level security (code security)
❌ Operating system configuration
❌ Network traffic content (requires packet inspection)
For those, use: SAST tools, DAST scanners, WAF, IDS/IPS