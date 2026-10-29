data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Index subnets by AZ name so adding an AZ later does not renumber existing ones.
  az_index = { for idx, az in local.azs : az => idx }
}

# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  # Both required for private DNS on VPC endpoints and for MGN host resolution.
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-vpc"
  }
}

# A new VPC's default security group allows all traffic between its members.
# Taking control of it and leaving it empty closes that. Security Hub flags this
# if you skip it.
resource "aws_default_security_group" "locked" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-default-DO-NOT-USE"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-igw"
  }
}

# ---------------------------------------------------------------------------
# Subnets
#
# Public  : 10.20.0.0/24,  10.20.1.0/24   (MGN staging + migrated app tier)
# Private : 10.20.10.0/24, 10.20.11.0/24  (database tier, no internet route)
#
# The MGN staging subnet is public and replication servers get public IPs.
# That is a deliberate cost decision: the alternative is a NAT gateway at
# roughly $33/month plus data processing, which is a large share of this
# project's entire budget. The exposure is mitigated by the staging security
# group, which accepts inbound only from source_public_ip. Recorded as ADR-005.
# ---------------------------------------------------------------------------

resource "aws_subnet" "public" {
  for_each = local.az_index

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-public-${each.key}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = local.az_index

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value + 10)

  tags = {
    Name = "${var.env}-private-${each.key}"
    Tier = "private"
  }
}

# ---------------------------------------------------------------------------
# Routing
# ---------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.env}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# No default route. The database tier reaches S3 through the gateway endpoint
# below and nothing else.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------------------------------
# S3 gateway endpoint
#
# Free. MGN pulls agent components and writes replication data via S3, so this
# keeps that traffic off the internet path and costs nothing.
# ---------------------------------------------------------------------------

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    [aws_route_table.private.id]
  )

  tags = {
    Name = "${var.env}-s3-endpoint"
  }
}
