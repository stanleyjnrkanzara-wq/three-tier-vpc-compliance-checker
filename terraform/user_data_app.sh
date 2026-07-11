#!/bin/bash
set -e

# Update system
yum update -y

# Install Python
yum install -y python3 python3-pip

# Create simple application
cat > /opt/app.py <<'APPEOF'
#!/usr/bin/env python3
import http.server
import socketserver
import json
import socket
import os

PORT = 8080

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = {
                "status": "healthy",
                "instance_id": socket.gethostname(),
                "environment": os.environ.get("ENVIRONMENT", "dev")
            }
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            html = b"""
            <html>
            <head><title>App Tier</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; }
                .success { color: green; font-size: 20px; }
            </style>
            </head>
            <body>
            <h1 class="success">✅ Application Tier Running!</h1>
            <p><strong>Database Host:</strong> """ + os.environ.get("DB_HOST", "not-set").encode() + b"""</p>
            <p><strong>This is the private application tier.</strong></p>
            <p>It receives requests from the web tier and communicates with the database.</p>
            </body>
            </html>
            """
            self.wfile.write(html)

if __name__ == '__main__':
    Handler = MyHTTPRequestHandler
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Server running on port {PORT}")
        httpd.serve_forever()
APPEOF

chmod +x /opt/app.py

# Create systemd service
cat > /etc/systemd/system/app.service <<SVCEOF
[Unit]
Description=Three-Tier App Tier
After=network.target

[Service]
Type=simple
User=ec2-user
Environment="ENVIRONMENT=${environment}"
Environment="DB_HOST=${db_endpoint}"
ExecStart=/usr/bin/python3 /opt/app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SVCEOF

systemctl daemon-reload
systemctl start app
systemctl enable app

echo "App tier user data script completed"