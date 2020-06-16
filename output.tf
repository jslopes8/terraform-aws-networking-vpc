output "aws_vpc_id" {
    description = "The ID of the VPC"
    value       = "${data.aws_vpc.selected.id}"
}

output "availability_zones" {
    value = [ "${var.avail_zones}" ]
}

output "ipv4_cidr" {
    value = "${data.aws_vpc.selected.cidr_block}"
}
    
output "tenancy" {
    value = "${aws_vpc.create_vpc.instance_tenancy}"
}
output "rt" {
    value = "${aws_vpc.create_vpc.default_route_table_id}"
}
output "acl" {
    value = "${aws_vpc.create_vpc.default_network_acl_id}"
}
output "dhcp" {
    value = "${aws_vpc.create_vpc.dhcp_options_id}"
}
output "nat_id" {
    value = "${aws_nat_gateway.nat-gw.*.id}"
}
output "nat_private_ip" {
    value = "${aws_nat_gateway.nat-gw.*.private_ip}"
}
output "nat_public_ip" {
    value = "${aws_nat_gateway.nat-gw.*.public_ip}"
}
output "network_interface_id" {
    value = "${aws_nat_gateway.nat-gw.*.network_interface_id}"
}
output "sn_priv" {
    value = [ "${aws_subnet.private-sn.*.cidr_block}"  ]
}
output "sn_pub" {
    value = [ "${aws_subnet.public-sn.*.cidr_block}" ]
}
