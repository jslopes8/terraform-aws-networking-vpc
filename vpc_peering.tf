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