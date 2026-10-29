# ---------------------------------------------------------------------------
# MGN staging area
#
# AWS Application Migration Service launches replication servers into the
# staging subnet. Source servers push replicated blocks to them on TCP 1500.
# Those servers also need outbound 443 to the MGN and S3 endpoints.
#
# Inbound is restricted to source_public_ip. Without that restriction the
# staging servers would accept 1500 from anywhere, which with public IPs is a
# real exposure, not a theoretical one.
# ---------------------------------------------------------------------------

resource "aws_security_group" "mgn_staging" {
  name        = "${var.env}-mgn-staging"
  description = "MGN replication servers. Inbound 1500 from the simulated source environment only."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.env}-mgn-staging"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mgn_replication" {
  security_group_id = aws_security_group.mgn_staging.id
  description       = "Replicated block data from source servers"
  cidr_ipv4         = var.source_public_ip
  from_port         = 1500
  to_port           = 1500
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "mgn_all_out" {
  security_group_id = aws_security_group.mgn_staging.id
  description       = "MGN service endpoint, S3, and agent component downloads"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------------------------------------------------------------------------
# Migrated application tier
# ---------------------------------------------------------------------------

resource "aws_security_group" "app" {
  name        = "${var.env}-app"
  description = "Migrated application server."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.env}-app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_http" {
  security_group_id = aws_security_group.app.id
  description       = "Application HTTP, for validation testing"
  cidr_ipv4         = var.admin_ip
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id = aws_security_group.app.id
  description       = "Administrative access from known IP only"
  cidr_ipv4         = var.admin_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_all_out" {
  security_group_id = aws_security_group.app.id
  description       = "Outbound for package updates and AWS service endpoints"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------------------------------------------------------------------------
# Migrated database tier
#
# Reachable only from the application security group. No path from the
# internet, and no inbound CIDR rule at all.
# ---------------------------------------------------------------------------

resource "aws_security_group" "db" {
  name        = "${var.env}-db"
  description = "Migrated database server. Reachable only from the application tier."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.env}-db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "Database connections from the application tier"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "db_all_out" {
  security_group_id = aws_security_group.db.id
  description       = "Outbound for updates and AWS service endpoints"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------------------------------------------------------------------------
# Supporting dependency tier
#
# The third VM. Hosts the service the application quietly relies on and which
# is deliberately absent from the dependency documentation.
# ---------------------------------------------------------------------------

resource "aws_security_group" "dependency" {
  name        = "${var.env}-dependency"
  description = "Supporting dependency service. Reachable only from the application tier."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.env}-dependency"
  }
}

resource "aws_vpc_security_group_ingress_rule" "dep_from_app" {
  security_group_id            = aws_security_group.dependency.id
  description                  = "Dependency service calls from the application tier"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "dep_all_out" {
  security_group_id = aws_security_group.dependency.id
  description       = "Outbound for updates and AWS service endpoints"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
