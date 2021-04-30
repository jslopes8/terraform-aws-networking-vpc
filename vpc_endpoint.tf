## VPC Endpoint

resource "aws_vpc_endpoint" "main" {
    count   = var.create ? length(var.vpc_endpoint) : 0

    epends_on = [ aws_vpc.main ]

    vpc_id       = aws_vpc.main.0.id
    service_name        = lookup(var.vpc_endpoint[count.index], "service_name", null)
    vpc_endpoint_type   = lookup(var.vpc_endpoint[count.index], "endpoint_type", null)
    private_dns_enabled = lookup(var.vpc_endpoint[count.index], "private_dns_enabled", "false")

    route_table_ids = [ aws_route_table.private.*.id, aws_route_table.public.*.id ]

    tags = merge({
        Name = "${var.vpc_name}-VPC_EP"
    }, var.default_tags)
}