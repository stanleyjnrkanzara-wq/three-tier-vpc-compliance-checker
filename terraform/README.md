# Terraform Deployment

Infrastructure-as-Code for the three-tier VPC + compliance checker.

## Quick Start

```bash
terraform init
terraform plan -var="email_address=your@email.com"
terraform apply -var="email_address=your@email.com"
```

## Files

- **main.tf**: All VPC, EC2, RDS, ALB, Lambda resources
- **variables.tf**: Input variable definitions
- **outputs.tf**: Output values after deployment
- **terraform.tfvars**: Your specific configuration (UPDATE THIS!)
- **user_data_web.sh**: Web server startup script
- **user_data_app.sh**: App server startup script
- **README.md**: This file

## Configuration

Edit **terraform.tfvars** before deployment:

```hcl
email_address = "stanleyjnrkanzara@gmail.com"    # REQUIRED
db_password = "StrongPassword123!@#"        # REQUIRED
```

## Deployment

```bash
cd terraform
terraform init          # Download providers
terraform plan          # Review changes
terraform apply         # Deploy infrastructure
```

Takes 10-15 minutes.

## Outputs

After deployment, see outputs:

```bash
terraform output deployment_summary
```

## Destroying

To delete all resources:

terraform destroy

## Cost

- **Free Tier Resources**: EC2 t3.micro, RDS t3.micro = Free
- **Paid Services**: ALB ~$0.50/day for testing
- **Total for 24-hour deployment**: ~$1-2

## Notes

This is the "Lite" version using:
- t3.micro instances (free tier eligible)
- db.t3.micro database (free tier eligible)
- No NAT Gateways (saves $64/month)
