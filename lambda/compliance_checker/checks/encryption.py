def check_encryption(ec2_client, rds_client):
    """
    Check encryption configuration across AWS resources
    """
    findings = []
    
    try:
        # Check RDS encryption
        dbs = rds_client.describe_db_instances()
        
        for db in dbs['DBInstances']:
            db_id = db['DBInstanceIdentifier']
            
            # Check storage encryption
            if not db.get('StorageEncrypted', False):
                findings.append({
                    'type': 'UNENCRYPTED_RDS_STORAGE',
                    'db_id': db_id,
                    'severity': 'CRITICAL',
                    'description': f'RDS database {db_id} storage is not encrypted'
                })
        
        if not findings:
            findings.append({
                'type': 'COMPLIANT',
                'description': 'Encryption is properly configured',
                'severity': 'INFO'
            })
        
    except Exception as e:
        findings.append({
            'type': 'ERROR',
            'description': f'Error checking encryption: {str(e)}',
            'severity': 'ERROR'
        })
    
    return findings