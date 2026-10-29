# Wave 0 — Landing Zone

The AWS foundation the pathfinder migrates into. Nothing migrates at this stage;
this builds the empty environment.

## What it creates

- VPC with DNS support and hostnames enabled
- Public subnets across 2 AZs (MGN staging + migrated application tier)
- Private subnets across 2 AZs (database tier, no internet route)
- Internet gateway, route tables, associations
- S3 gateway endpoint (free; keeps MGN's S3 traffic off the internet path)
- Default security group taken over and emptied
- Security groups: MGN staging, application, database, dependency

No NAT gateway. See ADR-005 for the cost reasoning and the mitigation.

## First run

The state bucket must exist before `init`. Create it once by hand:

    BUCKET=dc-exit-tfstate-logesh-$(date +%s)
    aws s3api create-bucket --bucket $BUCKET --region us-east-1
    aws s3api put-bucket-versioning --bucket $BUCKET \
      --versioning-configuration Status=Enabled
    aws s3api put-public-access-block --bucket $BUCKET \
      --public-access-block-configuration \
      BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

Then create `backend.hcl` with that bucket name:

    bucket       = "your-bucket-name"
    key          = "wave0/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true

Then:

    cp terraform.tfvars.example terraform.tfvars
    curl -s https://checkip.amazonaws.com        # put this in terraform.tfvars, with /32
    terraform init -backend-config=backend.hcl
    terraform validate
    terraform plan -out=wave0.tfplan
    terraform apply wave0.tfplan

## Feeding MGN

After apply, `terraform output` gives the two values the MGN replication settings
template needs:

- `mgn_staging_subnet_id`
- `mgn_staging_sg_id`

## Teardown

    terraform destroy

Everything here is free or near-free when idle except the EC2 instances MGN
launches, which are not managed by this configuration. Delete those through the
MGN console, and confirm staging volumes are gone after finalising cutover.

## Notes

- `source_public_ip` is your home public IP. Residential IPs change. If
  replication stops connecting, re-check it and re-apply.
- Changing `az_count` from 2 to 3 adds subnets without renumbering the existing
  ones, because subnets are keyed by AZ name rather than by position.
