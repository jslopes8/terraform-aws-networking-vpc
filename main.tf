## Get VPC ID
data "aws_vpc" "selected" {
    id = aws_vpc.main.0.id
}

## Create VPC  
resource "aws_vpc" "main" {
    count   = var.create ? 1 : 0

    cidr_block                          = var.cidr_block
    enable_dns_hostnames                = var.enable_dns_hostnames
    enable_dns_support                  = var.enable_dns_support
    instance_tenancy                    = var.instance_tenancy
    enable_classiclink                  = var.enable_classiclink
    enable_classiclink_dns_support      = var.enable_classiclink_dns_support 
    assign_generated_ipv6_cidr_block    = var.assign_generated_ipv6_cidr_block

    tags    = merge( 
        {
            Name = var.vpc_name
        },
        var.default_tags
    )
}
## DHCP
resource "aws_vpc_dhcp_options" "dhcp_opts" {
    count   = var.create ? length(var.dhcp_opts) : 0

    domain_name         = lookup(var.dhcp_opts[count.index], "domain_name", "${var.region}.compute.internal")
    domain_name_servers = lookup(var.dhcp_opts[count.index], "domain_name_servers", null)
        tags    = merge(
        {
            Name = lookup(var.dhcp_opts[count.index], "Name", "${var.vpc_name}-DHCP-Options")
        },
        var.default_tags
    )
}
resource "aws_vpc_dhcp_options_association" "dhcp-opts-assoc" {
    count   = var.create ? length(var.dhcp_opts) : 0
    
    vpc_id          = data.aws_vpc.selected.id
    dhcp_options_id = aws_vpc_dhcp_options.dhcp_opts.0.id
}

## Create VPC Subnet
# Public
resource "aws_subnet" "public" {
    depends_on = [ aws_vpc.main ]

    count   = var.create ? length(var.subnet_public) : 0

    vpc_id      = data.aws_vpc.selected.id

    cidr_block              = lookup(var.subnet_public[count.index], "cidr_block", null)
    availability_zone       = lookup(var.subnet_public[count.index], "availability_zone", null)
    map_public_ip_on_launch = lookup(var.subnet_public[count.index], "map_public_ip_on_launch", null)
    tags = merge(
        {
            Name = lookup(var.subnet_public[count.index], "tag_name", null)
        },
        lookup(var.subnet_public[count.index], "tag_public", null),
        var.default_tags
    )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
    count   = var.create && length(var.subnet_public) > 0 ? 1 : 0

    vpc_id  = data.aws_vpc.selected.id
    tags = merge(
        {
            Name = format( "%s", "${var.vpc_name}-InternetGateway")
        },
        var.default_tags
    )
}

# Route Table
resource "aws_route_table" "public" {
    depends_on = [ aws_vpc.main ]

    count   = var.create && length(var.subnet_public) > 0 ? 1 : 0

    vpc_id          = data.aws_vpc.selected.id

    route {
        cidr_block  = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.0.id
    }

    tags    = merge(
        {
            Name = "${var.vpc_name}-RouteTable-Public"
        },
        var.default_tags
    )
}
# Route Table Association
resource "aws_route_table_association" "public" {
    count   = var.create ? length(var.subnet_public) : 0

    route_table_id = element(aws_route_table.public.*.id, count.index)
    subnet_id = element(aws_subnet.public.*.id, count.index)
}
resource "aws_eip" "public" {
    count   = var.create && var.enable_nat_gateway ? length(var.subnet_public) : 0 

    vpc = true
    tags    = merge(
        {
            "Name" = "${var.vpc_name}-EIP"
        },
        var.default_tags
    )
}
resource "aws_nat_gateway" "public" {
    count   = var.create && var.enable_nat_gateway ? length(var.subnet_public) : 0  

    allocation_id = element(aws_eip.public.*.id, count.index)
    subnet_id     = element(aws_subnet.public.*.id, count.index)
    tags = merge(
        {
            Name = "${var.vpc_name}-NATGateway"
        },
        var.default_tags
    )
}
# Private
resource "aws_subnet" "private" {
    depends_on = [ aws_vpc.main ]

    count   = var.create ? length(var.subnet_private) : 0

    vpc_id      = data.aws_vpc.selected.id

    cidr_block              = lookup(var.subnet_private[count.index], "cidr_block", null)
    availability_zone       = lookup(var.subnet_private[count.index], "availability_zone", null)
    map_public_ip_on_launch = lookup(var.subnet_private[count.index], "map_public_ip_on_launch", null)
    tags = merge(
        {
            Name = lookup(var.subnet_private[count.index], "tag_name", null)
        },
        lookup(var.subnet_private[count.index], "tag_private", null),
        var.default_tags
    )
}

resource "aws_route_table" "private" {
    count   = var.create ? length(var.subnet_private) : 0

    vpc_id     = data.aws_vpc.selected.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.public.*.id, count.index)
    }
    tags = merge(
        {
            "Name" = format("%s", "${var.vpc_name}-RouteTable-Private")
        },
        var.default_tags
    )
    lifecycle {
        ignore_changes = [route]
    }
}
resource "aws_route_table_association" "private" {
    count   = var.create ? length(var.subnet_private) : 0

    route_table_id = element(aws_route_table.private.*.id, count.index)
    subnet_id = element(aws_subnet.private.*.id, count.index)
}

## Database
resource "aws_subnet" "database" {
    depends_on = [ aws_vpc.main ]

    count   = var.create ? length(var.subnet_database) : 0

    vpc_id      = data.aws_vpc.selected.id

    cidr_block              = lookup(var.subnet_database[count.index], "cidr_block", null)
    availability_zone       = lookup(var.subnet_database[count.index], "availability_zone", null)
    map_public_ip_on_launch = lookup(var.subnet_database[count.index], "map_public_ip_on_launch", null)
    tags = merge(
        {
            Name = lookup(var.subnet_database[count.index], "tag_name", null)
        },
        var.default_tags
    )
}
resource "aws_eip" "database" {
    count   = var.create ? length(var.subnet_database) : 0 

    vpc = true
    tags    = merge(
        {
            "Name" = "${var.vpc_name}-Database-ElasticIP"
        },
        var.default_tags
    )
}
resource "aws_nat_gateway" "database" {
    count   = var.create ? length(var.subnet_database) : 0   

    allocation_id = element(aws_eip.database.*.id, count.index)
    subnet_id     = element(aws_subnet.database.*.id, count.index)
    tags = merge(
        {
            Name = "${var.vpc_name}-Database-NATGateway"
        },
        var.default_tags
    )
}
resource "aws_route_table" "database" {
    count   = var.create ? length(var.subnet_database) : 0

    vpc_id     = data.aws_vpc.selected.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.database.*.id, count.index)
    }
    tags = merge(
        {
            "Name" = format("%s", "${var.vpc_name}-RouteTable-Database-Private")
        },
        var.default_tags
    )
}
resource "aws_route_table_association" "database" {
    count   = var.create ? length(var.subnet_database) : 0

    route_table_id = element(aws_route_table.database.*.id, count.index)
    subnet_id = element(aws_subnet.database.*.id, count.index)
}

resource "aws_db_subnet_group" "database" {
    count   = var.create && length(var.subnet_database) > 0 ? 1 : 0

    name       = "main"
    subnet_ids =  tolist(aws_subnet.database.*.id) 
    tags = merge(
        {
            "Name" = format("%s", "${var.vpc_name}-Database-Subnet-Group")
        },
        var.default_tags
    )
}
# Elasticache
resource "aws_subnet" "cache" {
    depends_on = [ aws_vpc.main ]

    count   = var.create ? length(var.subnet_cache) : 0

    vpc_id      = data.aws_vpc.selected.id

    cidr_block              = lookup(var.subnet_cache[count.index], "cidr_block", null)
    availability_zone       = lookup(var.subnet_cache[count.index], "availability_zone", null)
    map_public_ip_on_launch = lookup(var.subnet_cache[count.index], "map_public_ip_on_launch", null)
    tags = merge(
        {
            Name = lookup(var.subnet_cache[count.index], "tag_name", null)
        },
        var.default_tags
    )
}
resource "aws_eip" "cache" {
    count   = var.create ? length(var.subnet_cache) : 0 

    vpc = true
    tags    = merge(
        {
            "Name" = "${var.vpc_name}-ElastiCache-ElasticIP"
        },
        var.default_tags
    )
}
resource "aws_nat_gateway" "cache" {
    count   = var.create ? length(var.subnet_cache) : 0   

    allocation_id = element(aws_eip.cache.*.id, count.index)
    subnet_id     = element(aws_subnet.cache.*.id, count.index)
    tags = merge(
        {
            Name = "${var.vpc_name}-ElastiCache-NATGateway"
        },
        var.default_tags
    )
}
resource "aws_route_table" "cache" {
    count   = var.create ? length(var.subnet_cache) : 0

    vpc_id     = data.aws_vpc.selected.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.cache.*.id, count.index)
    }
    tags = merge(
        {
            "Name" = format("%s", "${var.vpc_name}-RouteTable-ElastiCache-Private")
        },
        var.default_tags
    )
}
resource "aws_route_table_association" "cache" {
    count   = var.create ? length(var.subnet_cache) : 0

    route_table_id = element(aws_route_table.cache.*.id, count.index)
    subnet_id = element(aws_subnet.cache.*.id, count.index)
}
resource "aws_elasticache_subnet_group" "cache" {
    count   = var.create && length(var.subnet_cache) > 0 ? 1 : 0

    name        = "${var.vpc_name}-Cache-Subnet-Group" 
    subnet_ids  = tolist(aws_subnet.cache.*.id)
}

## NACL
resource "aws_default_network_acl" "default" {
    count   = var.create ? 1 : 0

    default_network_acl_id = aws_vpc.main.0.default_network_acl_id

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
    lifecycle {
        ignore_changes = [ subnet_ids ]
    }
}

## SG
resource "aws_default_security_group" "default" {
    count   = var.create ? 1 : 0

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
####################################################
## VPC Flow Logs

resource "aws_flow_log" "vpc_flow_log" {
    count   = var.create ? length(var.flow_logs) : 0
    
    vpc_id          = data.aws_vpc.selected.id
    log_destination = aws_cloudwatch_log_group.cw-log-group.0.arn
    iam_role_arn    = aws_iam_role.flow_logs_role.0.arn
    traffic_type    = lookup(var.flow_logs[count.index], "traffic_type", null)
    log_format      = lookup(var.flow_logs[count.index], "log_format", null)
    tags = merge(
        {
        Name = "${var.vpc_name}-FlowLogs"
        },
        var.default_tags
    )

}
## VPC Flow Logs: CloudWatch, Log Group to store network traffic

resource "aws_cloudwatch_log_group" "cw-log-group" {
    count   = var.create ? length(var.flow_logs) : 0

    name                = "${var.vpc_name}-flow-log"
    retention_in_days   = lookup(var.flow_logs[count.index], "retention_in_days", null)
}
## VPC Flow Logs: IAM Role File, Store network logs
resource "aws_iam_role" "flow_logs_role" {
    count   = var.create ? length(var.flow_logs) : 0

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
    count   = var.create ? length(var.flow_logs) : 0

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

## VPC Peering
resource "aws_vpc_peering_connection" "main" {
    count   = var.create ? length(var.vpc_peering_connection) : 0

    depends_on = [ aws_vpc.main ]

    peer_vpc_id = lookup(var.vpc_peering_connection[count.index], "accepter_vpc_id", null)
    vpc_id      = aws_vpc.main.0.id
    peer_region = lookup(var.vpc_peering_connection[count.index], "accepter_vpc_region", null)

    tags    = var.default_tags
}
resource "aws_vpc_peering_connection_accepter" "main" {
    count   = var.create ? length(var.vpc_peering_connection) : 0

    vpc_peering_connection_id = aws_vpc_peering_connection.main.0.id
    auto_accept               = lookup(var.vpc_peering_connection[count.index], "auto_accept", null )

    tags    = var.default_tags
}

## VPN

resource "aws_vpn_gateway" "main" {
    count   = var.create ? length(var.vpn_customer_gateway) : 0

    depends_on = [ aws_vpc.main ]

    vpc_id = aws_vpc.main.0.id

    tags = var.default_tags
}

resource "aws_customer_gateway" "main" {
    count   = var.create ? length(var.vpn_customer_gateway) : 0

    depends_on = [ aws_vpc.main ]

    bgp_asn    = lookup(var.vpn_customer_gateway[count.index], "bgp_asn", null)
    ip_address = lookup(var.vpn_customer_gateway[count.index], "ip_address", null)
    type       = lookup(var.vpn_customer_gateway[count.index], "type", null)

    tags = var.default_tags
}

resource "aws_vpn_connection" "main" {
    count   = var.create ? length(var.vpn_customer_gateway) : 0

    depends_on = [ aws_vpc.main, aws_customer_gateway.main, aws_vpn_gateway.main ]

    vpn_gateway_id      = aws_vpn_gateway.main.0.id
    customer_gateway_id = aws_customer_gateway.main.0.id
    type                = lookup(var.vpn_customer_gateway[count.index], "type", null)
    static_routes_only  = lookup(var.vpn_customer_gateway[count.index], "static_routes_only", null)

    tags = var.default_tags
}
