def check_security_groups(ec2_client):
    """
    Check security groups for overly permissive rules
    """
    findings = []
    
    try:
        response = ec2_client.describe_security_groups()
        
        for sg in response['SecurityGroups']:
            sg_id = sg['GroupId']
            sg_name = sg['GroupName']
            vpc_id = sg.get('VpcId', 'default')
            
            # Check inbound rules
            for rule in sg.get('IpPermissions', []):
                # Check for 0.0.0.0/0 (open to world)
                for ip_range in rule.get('IpRanges', []):
                    if ip_range.get('CidrIp') == '0.0.0.0/0':
                        from_port = rule.get('FromPort', -1)
                        to_port = rule.get('ToPort', -1)
                        protocol = rule.get('IpProtocol', 'unknown')
                        
                        # Determine severity
                        critical_ports = [22, 3389, 1433, 3306, 5432, 27017, 5984, 9200]
                        severity = 'CRITICAL' if from_port in critical_ports else 'HIGH'
                        
                        port_range = f"{from_port}-{to_port}" if from_port != to_port else str(from_port)
                        if from_port == -1:
                            port_range = "All"
                        
                        findings.append({
                            'type': 'OVERLY_PERMISSIVE_SG',
                            'sg_id': sg_id,
                            'sg_name': sg_name,
                            'vpc_id': vpc_id,
                            'protocol': protocol,
                            'port_range': port_range,
                            'cidr': ip_range.get('CidrIp'),
                            'severity': severity,
                            'description': f"Security group allows {protocol}/{port_range} from 0.0.0.0/0"
                        })
        
        if not findings:
            findings.append({
                'type': 'COMPLIANT',
                'description': 'No overly permissive security groups detected',
                'severity': 'INFO'
            })
        
    except Exception as e:
        findings.append({
            'type': 'ERROR',
            'description': f'Error checking security groups: {str(e)}',
            'severity': 'ERROR'
        })
    
    return findings