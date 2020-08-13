output "vpc" {
    value = data.aws_vpc.selected.id
}
output "subnet_private" {
    value = length(aws_subnet.private) > 1 ? aws_subnet.private.*.cidr_block : null
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