###################################################################################################
# A VPC is an isolated portion of the AWS cloud populated by AWS objects, such as Amazon EC2 instances.
#
#

##############################################
## Create VPC

resource "aws_vpc" "create_vpc" {
    cidr_block                          = var.cidr_block
    enable_dns_hostnames                = var.enable_dns_hostnames
    enable_dns_support                  = var.enable_dns_support
    instance_tenancy                    = var.instance_tenancy
    assign_generated_ipv6_cidr_block    = var.assign_generated_ipv6_cidr_block
    tags    = merge( 
        {
            Name = var.vpc_name
        },
        var.default_tags
    )
}
# Data source get vpc_id
data "aws_vpc" "selected" {
    id = aws_vpc.create_vpc.id
}

###############################################
## VPC Flow Logs

resource "aws_flow_log" "vpc_flow_log" {
    count   = var.create ? length(var.flow_log) : 0
    
    vpc_id          = data.aws_vpc.selected.id
    log_destination = aws_cloudwatch_log_group.cw-log-group.0.arn
    iam_role_arn    = aws_iam_role.flow_logs_role.0.arn
    traffic_type    = lookup(var.flow_log[count.index], "traffic_type", "null")
}
## VPC Flow Logs: CloudWatch, Log Group to store network traffic

resource "aws_cloudwatch_log_group" "cw-log-group" {
    count   = var.create ? length(var.flow_log) : 0

    name                = "${var.vpc_name}-flow-log"
    retention_in_days   = lookup(var.flow_log[count.index], "retention_in_days", "null")
}
## VPC Flow Logs: IAM Role File, Store network logs
resource "aws_iam_role" "flow_logs_role" {
    count   = var.create ? length(var.flow_log) : 0

    name    =   "${var.vpc_name}-FlowLogsRole"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# VPC Flow Logs: Policy authorizing the IAM Role Network Logs
resource "aws_iam_role_policy" "flow_logs_policy" {
    count   = var.create ? length(var.flow_log) : 0

    name    =   "${var.vpc_name}-FlowLogsPolicy"
    role    =   aws_iam_role.flow_logs_role.0.id
    policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "${aws_cloudwatch_log_group.cw-log-group.0.arn}"
    }
  ]
}
EOF
}

######################################################################
## VPC DHCP Options Set

resource "aws_vpc_dhcp_options" "dhcp_opts" {
    domain_name         = "${var.region}.compute.internal"
    domain_name_servers = [ var.domain_name_servers ]
        tags    = merge(
        {
            Name = "${var.vpc_name}-DHCP-Options"
        },
        var.default_tags
    )
}
resource "aws_vpc_dhcp_options_association" "dhcp-opts-assoc" {
    vpc_id          = data.aws_vpc.selected.id
    dhcp_options_id = aws_vpc_dhcp_options.dhcp_opts.id
}

######################################################################
## Elastic IP VPC

resource "aws_eip" "eip_vpc" {
    count = length(var.avail_zones)

    vpc = true
    tags    = merge(
        {
            "Name" = format("%s-%s", "${var.vpc_name}-EIP", substr(element(var.avail_zones, count.index ), 8, 10),)
        },
        var.default_tags
    )
}

#####################################################################
## AWS Route Table

resource "aws_route_table" "vpc_rt" {
    vpc_id          = data.aws_vpc.selected.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags    = merge(
        {
            Name = "${var.vpc_name}-RouteTable-${var.region}"
        },
        var.default_tags
    )
}
resource "aws_route_table" "public-sn-rt" {
    vpc_id     = data.aws_vpc.selected.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags    = merge(
        {
            Name = "${var.vpc_name}-RouteTable-SNPublic"
        },
       var.default_tags
    )
}
resource "aws_route_table" "private-sn-rt" {
    count = length(var.avail_zones)

    vpc_id     = data.aws_vpc.selected.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.nat-gw.*.id, count.index)
    }
    tags = merge(
        {
            "Name" = format("%s-%s", "${var.vpc_name}-RouteTable-SNPrivate", substr(element(var.avail_zones, count.index ), 8, 10),)
        },
        var.default_tags
    )
}

######################################################################
## Associate routing table

# Route Table Public
resource "aws_route_table_association" "public-sn" {
    count = length(var.avail_zones)

    route_table_id = element(aws_route_table.public-sn-rt.*.id, count.index)
    subnet_id = element(aws_subnet.public-sn.*.id, count.index)
}

# Route Table Private
resource "aws_route_table_association" "private-sn" {
    count = length(var.avail_zones)

    route_table_id = element(aws_route_table.private-sn-rt.*.id, count.index)
    subnet_id = element(aws_subnet.private-sn.*.id, count.index)
}

#######################################################################
## Internet Gateway

resource "aws_internet_gateway" "igw" {
    vpc_id  = data.aws_vpc.selected.id
    tags = merge(
        {
            Name = "${var.vpc_name}-IGW"
        },
        var.default_tags
    )
}

#######################################################################
## Nat Gateway

resource "aws_nat_gateway" "nat-gw" {
    count = length(var.avail_zones)

    allocation_id = element(aws_eip.eip_vpc.*.id, count.index)
    subnet_id     = element(aws_subnet.public-sn.*.id, count.index)
    tags = merge(
        {
            Name = format("%s-%s", "${var.vpc_name}-NATGateway", substr(element(var.avail_zones, count.index ), 8, 10),)
        },
        var.default_tags
    )
}

########################################################################
## VPC Subnet

# SN Private
resource "aws_subnet" "private-sn" {
    count       = length(var.avail_zones)

    vpc_id                  = data.aws_vpc.selected.id 
    #cidr_block              = cidrsubnet(var.cidr_block, var.newbits, count.index)
    cidr_block              = var.subnet_priv_block
    availability_zone       = element(var.avail_zones, count.index) 
    map_public_ip_on_launch = var.map_public_ip_on_launch
    tags = merge(
        {
            Name = format("%s-%s", "${var.vpc_name}-SN-Private", substr(element(var.avail_zones, count.index ), 8, 10),) 
        },
        var.default_tags
    )
}

# SN Public
resource "aws_subnet" "public-sn" {
    count                   = length(var.avail_zones)

    vpc_id                  = data.aws_vpc.selected.id
    #cidr_block              = cidrsubnet(var.cidr_block, var.newbits, count.index + length(var.avail_zones)) 
    cidr_block              = var.subnet_pub_block
    availability_zone       = element(var.avail_zones, count.index)
    map_public_ip_on_launch = var.map_public_ip_on_launch_sn_pub
    tags = merge(
        {
            Name = format("%s-%s", "${var.vpc_name}-SN-Public", substr(element(var.avail_zones, count.index ), 8, 10),)
        },
        var.default_tags
    )
}

#######################################################################
## VPC Default Security Group

resource "aws_default_security_group" "sg_vpc_default" {
    count   = var.create_sg-default ? 1 : 0

    vpc_id  = data.aws_vpc.selected.id

    ingress {
        protocol  = -1
        self      = true
        from_port = 0
        to_port   = 0
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    tags = merge(
        {
        Name = "${var.vpc_name}-Default-Security-Group"
        },
        var.default_tags
    )
}

##########################################################################
## VPC Network ACLs

resource "aws_default_network_acl" "vpc_nw_acls" {
    count   = var.create_network_acl ? 1 : 0

    default_network_acl_id = aws_vpc.create_vpc.default_network_acl_id
    #vpc_id      = data.aws_vpc.selected.id
    #subnet_ids  = [ "${aws_subnet.private-sn.0.id}", "${aws_subnet.private-sn.1.id}", "${aws_subnet.public-sn.0.id}", "${aws_subnet.public-sn.1.id}" ]
    subnet_ids  = [ element(aws_subnet.private-sn.*.id, count.index), element(aws_subnet.public-sn.*.id, count.index) ]

    egress {
        protocol   = "-1"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        icmp_code  = 0
        icmp_type  = 0
        from_port  = 0
        to_port    = 0
    }

    ingress {
        protocol   = "-1"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        icmp_code  = 0
        icmp_type  = 0
        from_port  = 0
        to_port    = 0
    }
    tags = merge(
        {
        Name = "${var.vpc_name}-Network-ACL"
        },
        var.default_tags
    )
}
