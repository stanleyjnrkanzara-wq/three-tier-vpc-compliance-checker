def check_database(rds_client):
    """
    Check RDS database configuration
    """
    findings = []
    
    try:
        # Get all RDS instances
        response = rds_client.describe_db_instances()
        
        for db in response['DBInstances']:
            db_id = db['DBInstanceIdentifier']
            
            # Check Multi-AZ
            if not db.get('MultiAZ', False):
                findings.append({
                    'type': 'NO_MULTI_AZ',
                    'db_id': db_id,
                    'severity': 'HIGH',
                    'description': f'Database {db_id} is not Multi-AZ enabled'
                })
            
            # Check automated backups
            backup_retention = db.get('BackupRetentionPeriod', 0)
            if backup_retention < 7:
                findings.append({
                    'type': 'LOW_BACKUP_RETENTION',
                    'db_id': db_id,
                    'retention_days': backup_retention,
                    'severity': 'HIGH',
                    'description': f'Database {db_id} backup retention is {backup_retention} days (should be ≥7)'
                })
            
            # Check publicly accessible
            if db.get('PubliclyAccessible', False):
                findings.append({
                    'type': 'PUBLICLY_ACCESSIBLE_DB',
                    'db_id': db_id,
                    'severity': 'CRITICAL',
                    'description': f'Database {db_id} is publicly accessible (security risk)'
                })
            
            # Check deletion protection
            if not db.get('DeletionProtection', False):
                findings.append({
                    'type': 'NO_DELETION_PROTECTION',
                    'db_id': db_id,
                    'severity': 'MEDIUM',
                    'description': f'Database {db_id} does not have deletion protection enabled'
                })
        
        if not findings:
            findings.append({
                'type': 'COMPLIANT',
                'description': 'All databases are properly configured',
                'severity': 'INFO'
            })
        
    except Exception as e:
        findings.append({
            'type': 'ERROR',
            'description': f'Error checking databases: {str(e)}',
            'severity': 'ERROR'
        })
    
    return findings