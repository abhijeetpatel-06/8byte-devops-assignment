# myapp - AWS infra (Terraform)

Basic prod-ish setup for hosting a web app on AWS, Mumbai (`ap-south-1`) region.

## What this builds

- VPC (`10.0.0.0/16`) with 2 public + 2 private subnets across 2 AZs
- Internet Gateway + NAT Gateway (private subnets get outbound internet only)
- Application Load Balancer in the public subnets
- Auto Scaling Group of EC2 instances (app layer) in the private subnets, only reachable from the ALB
- RDS PostgreSQL instance in the private subnets, only reachable from the app servers
- Security groups scoped tightly between each layer (internet -> ALB -> app -> db)
- Remote state in S3 with DynamoDB locking

## Layout

```
backend.tf              # remote state config
provider.tf              # aws + random providers
variables.tf              # all configurable inputs
vpc.tf                     # VPC, subnets, IGW, NAT, route tables
security_groups.tf          # SGs for alb / app / rds
alb.tf                        # load balancer + target group + listener
ec2.tf                          # launch template + ASG for the app
rds.tf                            # postgres instance
outputs.tf                          # useful values after apply
terraform.tfvars.example              # copy -> terraform.tfvars and edit
bootstrap.sh                            # one-time script to create the state bucket/table
```

## First time setup

1. Make sure you've got AWS creds configured (`aws configure` or env vars) with
   enough permissions to create VPCs, EC2, RDS, IAM stuff etc.

2. Create the state bucket + lock table (only needs to be done once ever):

   ```bash
   ./bootstrap.sh
   ```

   If you already renamed things in `backend.tf`, update the bucket/table
   names in `bootstrap.sh` to match first.

3. Copy the example vars file and fill it in:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

4. Set the DB password as an env var - don't put it in tfvars or commit it anywhere:

   ```bash
   export TF_VAR_db_password="something-strong-here"
   ```

5. Init, plan, apply:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

6. Once it's up, grab the ALB address:

   ```bash
   terraform output alb_dns_name
   ```

   Hit that in the browser / curl it, should get a "hello from myapp" back
   (that's just the placeholder user_data script in ec2.tf - swap it out
   for your real deploy process).

## Notes / things to change before real prod use

- `single_nat_gateway = true` saves money but means if that one NAT gateway's
  AZ goes down, all private subnet outbound traffic dies with it. Flip to
  `false` if you want one NAT per AZ.
- No HTTPS listener yet - add an ACM cert + 443 listener in `alb.tf` once you
  have a domain.
- `db_deletion_protection` defaults to `false` so this is easy to tear down
  while testing. Set it to `true` for anything real.
- The EC2 user_data in `ec2.tf` is just a dummy python http server so the
  health check passes out of the box. Replace with your actual app
  bootstrap / CodeDeploy / whatever you use to ship code.
- Consider moving DB creds to Secrets Manager instead of a plain tfvar /
  env var once this is more than a POC.

## Tearing it down

```bash
terraform destroy
```

(will fail if `db_deletion_protection = true` - turn that off first, on purpose)
