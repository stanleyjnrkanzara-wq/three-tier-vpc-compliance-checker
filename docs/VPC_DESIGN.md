# 🌐 VPC Network Design Details

Detailed specification of every networking decision.

## IP Addressing Scheme

### Primary VPC

```bash 

VPC: 10.0.0.0/16
Total Addresses: 65,536 (minus reserved by AWS)
Usable Addresses: ~65,500
Reserved by AWS per subnet:
├─ Network address: 10.0.x.0
├─ AWS gateway: 10.0.x.1
├─ AWS reserved: 10.0.x.2
├─ AWS reserved: 10.0.x.3
└─ Broadcast: 10.0.x.255
Available per subnet: 256 - 5 = 251 addresses

```
---

### Subnet Allocation

```bash

PUBLIC SUBNETS (Web Layer):
├─ Public Subnet 1 (AZ-a): 10.0.1.0/24    (251 usable)
└─ Public Subnet 2 (AZ-b): 10.0.2.0/24    (251 usable)
PRIVATE APP SUBNETS:
├─ App Subnet 1 (AZ-a): 10.0.11.0/24      (251 usable)
└─ App Subnet 2 (AZ-b): 10.0.12.0/24      (251 usable)
PRIVATE DB SUBNETS:
├─ DB Subnet 1 (AZ-a): 10.0.21.0/24       (251 usable)
└─ DB Subnet 2 (AZ-b): 10.0.22.0/24       (251 usable)
FUTURE EXPANSION (available):
├─ 10.0.3.0/24 - 10.0.10.0/24 (8 subnets)
├─ 10.0.13.0/24 - 10.0.20.0/24 (8 subnets)
└─ 10.0.23.0/24 - 10.0.255.0/24 (232 subnets!)

```
---

## Availability Zone Distribution

```bash

AVAILABILITY ZONE A (us-east-1a)
└─ Public: 10.0.1.0/24
├─ ALB Primary: 10.0.1.5
└─ Web Servers: 10.0.1.10 - 10.0.1.100
└─ App Private: 10.0.11.0/24
└─ App Servers: 10.0.11.10 - 10.0.11.100
└─ DB Private: 10.0.21.0/24
└─ RDS Replica: 10.0.21.10
AVAILABILITY ZONE B (us-east-1b)
└─ Public: 10.0.2.0/24
├─ ALB Secondary: 10.0.2.5
└─ Web Servers: 10.0.2.10 - 10.0.2.100
└─ App Private: 10.0.12.0/24
└─ App Servers: 10.0.12.10 - 10.0.12.100
└─ DB Private: 10.0.22.0/24
└─ RDS Primary: 10.0.22.10

```
---

## Route Tables

### Public Route Table

```bash

All public subnets use the same route table:
Destination      | Target          | Type
─────────────────|─────────────────|─────────────
10.0.0.0/16      | Local           | Intra-VPC
0.0.0.0/0        | igw-xxxxx       | Internet Gateway
What this means:
├─ Traffic within VPC (10.0.x.x) → stays in VPC (free)
└─ Traffic to internet (0.0.0.0/0) → goes to IGW (charged)

```
---

### Private App Route Tables

```bash

**AZ-a Table:**
Destination      | Target          | Type
─────────────────|─────────────────|─────────────
10.0.0.0/16      | Local           | Intra-VPC
0.0.0.0/0        | igw-xxxxx       | IGW (for testing)

```

**AZ-b Table:**
Same as AZ-a (for testing purposes)

**Note:** In production, would use NAT Gateways instead of IGW for private subnets.

### Private DB Route Table

```bash
Destination      | Target          | Type
─────────────────|─────────────────|─────────────
10.0.0.0/16      | Local           | Intra-VPC

```
(No default route - database is isolated)
What this means:
└─ Database CANNOT reach internet (intentional)
└─ Database can ONLY reach other VPC resources

## Network Access Control Lists (NACLs)

NACLs add an additional stateless firewall layer (beyond Security Groups).

### Public Subnet NACL
Inbound Rules:

```bash

Rule #  | Type    | Protocol | Port Range | CIDR       | Action
─────────────────────────────────────────────────────────────────
100     | HTTP    | TCP      | 80         | 0.0.0.0/0  | ALLOW
101     | HTTPS   | TCP      | 443        | 0.0.0.0/0  | ALLOW
102     | Ephemeral| TCP     | 1024-65535 | 0.0.0.0/0  | ALLOW


  | All     | All      | All        | All        | DENY

  ```


Outbound Rules:

```bash

Rule #  | Type    | Protocol | Port Range | CIDR       | Action
─────────────────────────────────────────────────────────────────
100     | All     | All      | All        | 0.0.0.0/0  | ALLOW


  | All     | All      | All        | All        | DENY
 

```

### Private App Subnet NACL

Inbound Rules:

```bash
Rule #  | Type    | Protocol | Port Range | CIDR       | Action
─────────────────────────────────────────────────────────────────
100     | Custom  | TCP      | 8080       | 10.0.0.0/16| ALLOW
101     | Ephemeral| TCP    | 1024-65535 | 10.0.0.0/16| ALLOW


  | All     | All      | All        | All        | DENY

```

Outbound Rules:

```bash
Rule #  | Type    | Protocol | Port Range | CIDR       | Action
─────────────────────────────────────────────────────────────────
100     | All     | All      | All        | 0.0.0.0/0  | ALLOW


  | All     | All      | All        | All        | DENY

```

### Private DB Subnet NACL

Inbound Rules:

```bash
Rule #  | Type    | Protocol | Port Range | CIDR       | Action
─────────────────────────────────────────────────────────────────
100     | MySQL   | TCP      | 3306       | 10.0.0.0/16| ALLOW
101     | Ephemeral| TCP    | 1024-65535 | 10.0.0.0/16| ALLOW


  | All     | All      | All        | All        | DENY

```
Outbound Rules:

```bash
Rule #  | Type    | Protocol | Port Range | CIDR       | Action
─────────────────────────────────────────────────────────────────
(All explicitly denied - DB doesn't initiate outbound)


  | All     | All      | All        | All        | DENY

```
---

## Security Groups (Detailed)

### Web Tier Security Group: `dev-web-tier-sg`


Inbound Rules:
```bash
PortProtocolSourceDescription80TCP0.0.0.0/0HTTP from internet443TCP0.0.0.0/0HTTPS from internet
```
Outbound Rules:
```bash
DestinationProtocolPortDescription0.0.0.0/0AllAllCan reach app tier + internet
```

What's Blocked:
```bash
├─ SSH (port 22) - no direct access
├─ RDP (port 3389) - no direct access
└─ Database port (3306) - can't reach DB directly
```

### App Tier Security Group: `dev-app-tier-sg`

Inbound Rules:
```bash
PortProtocolSourceDescription8080TCPdev-web-tier-sgOnly from web tier
```
Outbound Rules:
```bash
DestinationProtocolPortDescription0.0.0.0/0AllAllCan reach database + internet
```

What's Blocked:
```bash
├─ Port 80/443 - can't receive from internet
├─ Port 22 - no SSH access
└─ Port 3306 - only via app tier routing
```

---

### DB Tier Security Group: `dev-db-tier-sg`

Inbound Rules:
```bash
PortProtocolSourceDescription3306TCPdev-app-tier-sgOnly from app tier
```

Outbound Rules:
```bash
(None - databases should NOT initiate connections)
What's Blocked:
├─ Anything from internet
├─ Anything from web tier
└─ Any outbound traffic
```
---

## Traffic Flows

### User → Web Server
```bash
User Browser (203.0.113.50:54321)
│
├─ DNS Lookup: app-12345.us-east-1.elb.amazonaws.com
│
└─ HTTP GET (203.0.113.50:54321 → 203.0.113.200:80)
↓
AWS Internet Gateway
│
├─ Check Security Group (web-tier-sg)
│  ├─ Inbound: Port 80 from 0.0.0.0/0? YES ✅
│  └─ Check NACL: Inbound rule 101 (HTTP)? YES ✅
│
├─ Route to ALB Target Group
│  └─ Healthy targets: 10.0.1.10, 10.0.2.10
│
└─ Forward to Web Server
└─ Apache on 10.0.1.10:80
├─ Check Security Group: Allow HTTP? YES ✅
└─ Return HTML
↓
Back to user via same path
```

### Web Server → App Server
```bash
Web Server (10.0.1.10:54321)
│
├─ DNS/IP Lookup: app server (10.0.11.10 or 10.0.12.10)
│
└─ TCP SYN (10.0.1.10:54321 → 10.0.11.10:8080)
↓
VPC Internal (no internet gateway needed)
│
├─ Route Table: 10.0.11.0/24 in VPC? YES ✅
├─ Check Security Group (app-tier-sg)
│  ├─ Inbound: Port 8080 from dev-web-tier-sg? YES ✅
│  └─ Check NACL: Port 8080 from 10.0.0.0/16? YES ✅
│
└─ Deliver to App Server (10.0.11.10:8080)
├─ Python app listening
└─ Return response
↓
Back to web server (stateful - return path automatic)
```

### App Server → Database

```bash
App Server (10.0.11.10:54321)
│
├─ DNS Lookup: RDS Endpoint (dev-mysql-db.xxxxx.rds.amazonaws.com)
├─ Resolves to: 10.0.22.10 (RDS Primary in AZ-b)
│
└─ MySQL Protocol (SSL/TLS required)
(10.0.11.10:54321 → 10.0.22.10:3306)
↓
VPC Internal
│
├─ Route Table: 10.0.22.0/24 in VPC? YES ✅
├─ Check Security Group (db-tier-sg)
│  ├─ Inbound: Port 3306 from dev-app-tier-sg? YES ✅
│  └─ Check NACL: Port 3306 from 10.0.0.0/16? YES ✅
│
├─ SSL/TLS Handshake (encryption established)
│
└─ MySQL Query executed on RDS
├─ Data encrypted in transit
├─ Data encrypted at rest
└─ Return results
↓
Back to app server (stateful - return path automatic)
```

---

## Performance Considerations

### Bandwidth & Latency

```bash
Same Availability Zone:
├─ Latency: <1ms (within same physical cluster)
├─ Bandwidth: No limit (no charges)
└─ Example: Web server in 1a to App server in 1a
Cross Availability Zone:
├─ Latency: <5ms (still same region)
├─ Bandwidth: No limit (within region - no charges)
├─ Example: Web server in 1a to App server in 1b
└─ Note: Multi-AZ worth it for HA
Internet:
├─ Latency: 10-100ms (depends on user location)
├─ Bandwidth: Charges apply for data OUT
└─ Example: User in 203.0.113.0 to ALB
```

### Data Transfer Costs
```bash
FREE:
├─ Intra-VPC (10.0.0.0/16 to 10.0.0.0/16): $0.00
├─ Same AZ data transfer: $0.00
└─ Internet Gateway inbound: $0.00
CHARGED:
├─ Data OUT to internet: $0.02/GB
├─ Data OUT to another region: $0.02/GB
└─ NAT Gateway (if used): $0.045/hour + $0.045/GB
Expected Costs:
├─ Small deployment (100 MB/month data): <$1
├─ Medium deployment (10 GB/month data): $0.20
└─ Large deployment (1 TB/month data): $20

```
---

## Troubleshooting Network Issues

### Can't reach web server from internet

**Check:**
1. ALB in correct subnets? (public_1 + public_2)
2. Security group allows 80/443?
3. Route table has IGW route?
4. EC2 instance is running?
5. Web server application is responding?

### Can't reach app server from web server

**Check:**
1. App tier subnet route table configured?
2. App security group allows 8080 from web-tier-sg?
3. App server is running?
4. Firewall on EC2 allowing 8080?

### Can't reach database from app server

**Check:**
1. RDS is in DB tier subnets?
2. DB security group allows 3306 from app-tier-sg?
3. RDS "require_secure_transport" enabled?
4. Connection string using SSL/TLS?

### Slow network performance

**Check:**
1. Are servers cross-AZ? (Add latency)
2. Is network saturated? (Check CloudWatch metrics)
3. Are there many route table lookups? (Simplify routes)

---

This detailed specification ensures your VPC is optimized for security, performance, and cost!