def check_networking(ec2_client):
    """
    Check VPC networking configuration
    """
    findings = []
    
    try:
        # Check for VPC Flow Logs
        vpcs = ec2_client.describe_vpcs()
        
        for vpc in vpcs['Vpcs']:
            vpc_id = vpc['VpcId']
            
            # Check if Flow Logs are enabled
            flow_logs = ec2_client.describe_flow_logs(
                Filter=[
                    {
                        'Name': 'resource-id',
                        'Values': [vpc_id]
                    }
                ]
            )
            
            if not flow_logs['FlowLogs']:
                findings.append({
                    'type': 'MISSING_VPC_FLOW_LOGS',
                    'vpc_id': vpc_id,
                    'severity': 'HIGH',
                    'description': f'VPC {vpc_id} does not have Flow Logs enabled'
                })
        
        # Check Internet Gateways
        igws = ec2_client.describe_internet_gateways()
        
        if not igws['InternetGateways']:
            findings.append({
                'type': 'NO_INTERNET_GATEWAY',
                'severity': 'MEDIUM',
                'description': 'No Internet Gateways found in the account'
            })
        
        if not findings:
            findings.append({
                'type': 'COMPLIANT',
                'description': 'Network configuration is compliant',
                'severity': 'INFO'
            })
        
    except Exception as e:
        findings.append({
            'type': 'ERROR',
            'description': f'Error checking networking: {str(e)}',
            'severity': 'ERROR'
        })
    
    return findings