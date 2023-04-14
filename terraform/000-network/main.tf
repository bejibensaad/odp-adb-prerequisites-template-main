resource "aws_subnet" "databricksubnet_1" {
  vpc_id            = var.odb_vpcid
  cidr_block        = var.dabricks_subnet1
  availability_zone = var.availabilities_zones[0]
  tags = {
    "Name" = "databricks_subnet_1"
  }
}

resource "aws_subnet" "databricksubnet_2" {
  vpc_id            = var.odb_vpcid
  cidr_block        = var.dabricks_subnet2
  availability_zone = var.availabilities_zones[1]
  tags = {
    "Name" = "databricks_subnet_2"
  }
}

resource "aws_subnet" "subnet_4private_natgw" {
  vpc_id            = var.odb_vpcid
  cidr_block        = var.nat_subnet
  availability_zone = var.availabilities_zones[2]
  tags = {
    "Name" = "databricks_nat_subnet"
  }
}

#-------------------nat gw---------------------
resource "aws_nat_gateway" "NATgw" {
  subnet_id         = aws_subnet.subnet_4private_natgw.id
  connectivity_type = "private"
}


#--------------------route table-----------------
resource "aws_route_table" "odb_PrivateRT" {
  vpc_id = var.odb_vpcid
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
  tags = {
    Name = "databricks_route_table"
  }
}

#---------------------route for databricks subnet-------
resource "aws_route_table_association" "PrivateRTassociation" {
  subnet_id      = aws_subnet.databricksubnet_1.id
  route_table_id = aws_route_table.odb_PrivateRT.id
}

resource "aws_route_table_association" "Privatertassociation" {
  subnet_id      = aws_subnet.databricksubnet_2.id
  route_table_id = aws_route_table.odb_PrivateRT.id
}

resource "aws_route_table_association" "Privatertassociation_for_nat_subnet" {
  subnet_id      = aws_subnet.subnet_4private_natgw.id
  route_table_id = var.route_table_id
}

#----------------create sg---------------------------------
resource "aws_security_group" "databricks-control-plane" {
  name        = "sg_adb"
  description = "controls the inbound and outbound traffic for the instances"
  vpc_id      = var.odb_vpcid

}

#---------------create sg rules ingress---------------------------
resource "aws_security_group_rule" "all_udp_ingress" {
  description              = "All ingress udp traffic"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.databricks-control-plane.id
  security_group_id        = aws_security_group.databricks-control-plane.id
}

resource "aws_security_group_rule" "all_tcp_ingress" {
  description              = "All ingress tcp traffic"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.databricks-control-plane.id
  security_group_id        = aws_security_group.databricks-control-plane.id
}

#---------------create sg rules egress---------------------------
resource "aws_security_group_rule" "all_udp_egress" {
  description       = "Allow all UDP access to the workspace security group (for internal traffic)"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.databricks-control-plane.id
}

resource "aws_security_group_rule" "all_tcp_egress" {
  description       = "Allow all TCP access to the workspace security group (for internal traffic)"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.databricks-control-plane.id
}

resource "aws_security_group_rule" "all_egress_https" {
  description       = "For Databricks infrastructure, cloud data sources, and library repositories"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.databricks-control-plane.id
}

resource "aws_security_group_rule" "all_egress_mysql" {
  description       = "for the metastore"
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.databricks-control-plane.id
}

resource "aws_security_group_rule" "all_egress_customtcp" {
  description       = "for the PrivateLink"
  type              = "egress"
  from_port         = 6666
  to_port           = 6666
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.databricks-control-plane.id
}

#------------------create nacl------------------------------
resource "aws_network_acl" "databricks_nacl" {
  vpc_id     = var.odb_vpcid
  subnet_ids = [aws_subnet.databricksubnet_1.id, aws_subnet.databricksubnet_2.id]

}

#----------------nacl rules----------------------------------


resource "aws_network_acl_rule" "ingress_nacl" {
  network_acl_id = aws_network_acl.databricks_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "egress_nacl" {
  network_acl_id = aws_network_acl.databricks_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "100.64.0.0/16"
}
#resource "aws_network_acl_rule" "egress_nacl_tcp" {
#  network_acl_id = aws_network_acl.databricks_nacl.id
#  rule_number    = 200
#  egress         = true
#  protocol       = "tcp"
#  rule_action    = "allow"
#  cidr_block     = "0.0.0.0/0"
#  from_port      = 0
#  to_port        = 65535
#}

resource "aws_network_acl_rule" "egress_nacl_https" {
  network_acl_id = aws_network_acl.databricks_nacl.id
  rule_number    = 300
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "egress_nacl_mysql" {
  network_acl_id = aws_network_acl.databricks_nacl.id
  rule_number    = 400
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3306
  to_port        = 3306
}

resource "aws_network_acl_rule" "egress_nacl_alltcp" {
  network_acl_id = aws_network_acl.databricks_nacl.id
  rule_number    = 500
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 6666
  to_port        = 6666
}


#------------------vpc endpoint----------------

resource "aws_vpc_endpoint" "databricks-eu-central-1-workspace-vpce-scc" {
  vpc_id            = var.odb_vpcid
  service_name      = var.endpointscc_databricks
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    aws_security_group.databricks-control-plane.id
  ]
  subnet_ids          = [aws_subnet.databricksubnet_1.id]
  private_dns_enabled = true
  tags = {
    "name" = "odp-scc-endpoint"
  }

}

resource "aws_vpc_endpoint" "databricks-eu-central-1-workspace-vpce-rest" {
  vpc_id            = var.odb_vpcid
  service_name      = var.endpointrest_databricks
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.databricks-control-plane.id
  ]
  subnet_ids          = [aws_subnet.databricksubnet_1.id]
  private_dns_enabled = false
  tags = {
    "name" = "odp-rest-endpoint"
  }

}
