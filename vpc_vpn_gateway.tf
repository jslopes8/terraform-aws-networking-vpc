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