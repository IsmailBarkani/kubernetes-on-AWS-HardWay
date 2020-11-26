resource "aws_security_group" "security-group-cluster" {
  vpc_id = aws_vpc.main.id
  name   = "security-group-cluster"
}

# Allow outgoing connectivity
resource "aws_security_group_rule" "allow_all_outbound_from_cluster" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group-cluster.id
}

# Allow SSH connections only from specific CIDR (TODO)
resource "aws_security_group_rule" "allow_ssh_from_cidr" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group-cluster.id
}

# Allow the security group members to talk with each other without restrictions
resource "aws_security_group_rule" "allow_cluster_crosstalk" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.security-group-cluster.id
  security_group_id        = aws_security_group.security-group-cluster.id
}

# Allow API connections only from specific CIDR (TODO)
resource "aws_security_group_rule" "allow_api_from_cidr" {
  #count     = length(var.api_access_cidr)
  type      = "ingress"
  from_port = 6443
  to_port   = 6443
  protocol  = "tcp"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group-cluster.id
}
