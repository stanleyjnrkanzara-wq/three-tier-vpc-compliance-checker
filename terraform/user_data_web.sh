#!/bin/bash
set -e

# Update system
yum update -y

# Install Apache
yum install -y httpd

# Create simple health check page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Web Tier - Three-Tier VPC</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .success { color: green; font-size: 24px; }
    </style>
</head>
<body>
    <h1 class="success">✅ Web Tier is Running!</h1>
    <p><strong>Environment:</strong> ${environment}</p>
    <p><strong>Instance ID:</strong> $(ec2-metadata --instance-id | cut -d " " -f 2)</p>
    <p><strong>Availability Zone:</strong> $(ec2-metadata --availability-zone | cut -d " " -f 2)</p>
    <p><strong>Region:</strong> $(echo $(ec2-metadata --availability-zone | cut -d " " -f 2) | sed 's/[a-z]$//')</p>
    <hr>
    <p>This is the public web tier. It can be accessed from the internet via the ALB.</p>
</body>
</html>
EOF

# Start Apache
systemctl start httpd
systemctl enable httpd

echo "Web tier user data script completed"