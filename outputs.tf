output "id" {
    value = data.aws_vpc.selected.id
}
output "subnet_private" {
    value = length(aws_subnet.private) > 1 ? aws_subnet.private.*.cidr_block : null
}
output "subnet_private_id" {
    value = length(aws_subnet.private) > 1 ? aws_subnet.private.*.id : null
}
output "subnet_public_id" {
    value = length(aws_subnet.private) > 1 ? aws_subnet.public.*.id : null
}
output "subnet_public" {
    value = length(aws_subnet.public) > 1 ? aws_subnet.public.*.cidr_block : null
}
output "subnet_database" {
    value = length(aws_subnet.database) > 1 ? aws_subnet.public.*.cidr_block : null
}
output "internet_gateway" {
    value = length(aws_internet_gateway.main) > 1 ? aws_internet_gateway.main.0.id : null 
}
output "elastic_ip" {
    value = length(aws_eip.public) > 1 ? aws_eip.public.0.public_ip : null
}
output "elastic_ip_database" {
    value = length(aws_eip.database) > 1 ? aws_eip.database.0.public_ip : null
}
output "subnet_db" {
    value = length(aws_db_subnet_group.database) > 1 ? aws_db_subnet_group.database.*.id : null
} 
output "vpc_peering_id" {
    value = aws_vpc_peering_connection.main.0.id
}
output "rt_private_id" {
    value = length(aws_route_table.private) > 1 ? aws_route_table.private.*.id : null
}
output "rt_public_id" {
    value = length(aws_route_table.public) > 1 ? aws_route_table.public.*.id : null
}