import boto3
import json
import os
from datetime import datetime, timedelta
from checks.security_groups import check_security_groups
from checks.networking import check_networking
from checks.database import check_database
from checks.encryption import check_encryption

# Initialize AWS clients
ec2_client = boto3.client('ec2', region_name='us-east-1')
rds_client = boto3.client('rds', region_name='us-east-1')
sns_client = boto3.client('sns', region_name='us-east-1')
lambda_client = boto3.client('lambda', region_name='us-east-1')

def lambda_handler(event, context):
    """
    Main Lambda handler for VPC compliance checker
    """
    
    try:
        print("🔍 Starting VPC Compliance Scan...")
        
        # Step 1: Run all compliance checks
        print("📋 Running security group checks...")
        sg_findings = check_security_groups(ec2_client)
        
        print("🌐 Running networking checks...")
        network_findings = check_networking(ec2_client)
        
        print("🗄️  Running database checks...")
        db_findings = check_database(rds_client)
        
        print("🔐 Running encryption checks...")
        encryption_findings = check_encryption(ec2_client, rds_client)
        
        # Combine all findings
        all_findings = {
            "security_groups": sg_findings,
            "networking": network_findings,
            "database": db_findings,
            "encryption": encryption_findings
        }
        
        # Count violations by severity
        critical_count = count_findings_by_severity(all_findings, "CRITICAL")
        high_count = count_findings_by_severity(all_findings, "HIGH")
        medium_count = count_findings_by_severity(all_findings, "MEDIUM")
        
        print(f"📊 Findings - CRITICAL: {critical_count}, HIGH: {high_count}, MEDIUM: {medium_count}")
        
        # Step 2: Send report via SNS
        print("📧 Sending compliance report via SNS...")
        send_compliance_report(all_findings, critical_count, high_count, medium_count)
        
        print("✅ Compliance scan complete!")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Compliance scan complete',
                'critical_violations': critical_count,
                'high_violations': high_count,
                'medium_violations': medium_count
            })
        }
        
    except Exception as e:
        print(f"❌ Error during compliance scan: {str(e)}")
        import traceback
        traceback.print_exc()
        send_error_notification(str(e))
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }


def count_findings_by_severity(findings, severity):
    """Count findings by severity level"""
    count = 0
    for category, items in findings.items():
        if isinstance(items, list):
            for item in items:
                if isinstance(item, dict) and item.get('severity') == severity:
                    count += 1
    return count


def send_compliance_report(findings, critical, high, medium):
    """
    Send formatted compliance report via SNS
    """
    try:
        sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
        
        if not sns_topic_arn:
            print("Error: SNS_TOPIC_ARN environment variable not set")
            return
        
        # Build email subject
        subject = f"VPC Compliance Report - {datetime.now().strftime('%Y-%m-%d')}"
        if critical > 0:
            subject = f"🚨 URGENT: {subject} ({critical} Critical Issues)"
        elif high > 0:
            subject = f"⚠️  {subject} ({high} High Priority Issues)"
        
        # Build email body
        message_body = f"""
╔════════════════════════════════════════════════════════════╗
║          VPC COMPLIANCE AUDIT REPORT                       ║
╚════════════════════════════════════════════════════════════╝

Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

════════════════════════════════════════════════════════════
📊 VIOLATION SUMMARY
════════════════════════════════════════════════════════════

🚨 CRITICAL Violations: {critical}
⚠️  HIGH Violations: {high}
⚡ MEDIUM Violations: {medium}

════════════════════════════════════════════════════════════
📋 DETAILED FINDINGS
════════════════════════════════════════════════════════════

SECURITY GROUPS:
{json.dumps(findings.get('security_groups', []), indent=2, default=str)}

NETWORKING:
{json.dumps(findings.get('networking', []), indent=2, default=str)}

DATABASE:
{json.dumps(findings.get('database', []), indent=2, default=str)}

ENCRYPTION:
{json.dumps(findings.get('encryption', []), indent=2, default=str)}

════════════════════════════════════════════════════════════
✅ NEXT STEPS
════════════════════════════════════════════════════════════

1. Review CRITICAL findings immediately
2. Implement HIGH priority recommendations within 24 hours
3. Schedule MEDIUM priority items for next sprint

Next compliance scan: Tomorrow at 8:00 AM UTC

════════════════════════════════════════════════════════════
Report generated by: VPC Compliance Checker (Lambda)
"""
        
        # Send via SNS
        sns_client.publish(
            TopicArn=sns_topic_arn,
            Subject=subject,
            Message=message_body
        )
        
        print("✅ Compliance report sent via SNS")
        
    except Exception as e:
        print(f"Error sending report: {str(e)}")


def send_error_notification(error_msg):
    """
    Send error notification via SNS
    """
    try:
        sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
        
        if not sns_topic_arn:
            print("Error: SNS_TOPIC_ARN environment variable not set")
            return
        
        sns_client.publish(
            TopicArn=sns_topic_arn,
            Subject=f"🚨 VPC Compliance Checker Error - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            Message=f"""
Compliance scan encountered an error:

{error_msg}

Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

Please check the Lambda logs for more details.
"""
        )
        
    except Exception as e:
        print(f"Could not send error notification: {str(e)}")