variable "create" {
    type    = bool
    default = true
}
variable "create_sg-default" {
    type = bool
    default = true
}
variable "create_network_acl" {
    type = bool
    default = true
}
variable "vpc_name" {
    type = string
}
variable "region" {
    type = string
}
variable "avail_zones" {
    type = list
    default = []
}
variable "assign_generated_ipv6_cidr_block" {
    type = bool
    default = false
}
variable "cidr_block" {
    description = " You must specify an IPv4 address range for your VPC"
    type = string
    default = "0.0.0.0/0"
}
variable "enable_dns_hostnames" {
    type = bool
    default = true
}
variable "enable_dns_support" {
    type = bool
    default = true
}
variable "instance_tenancy" {
    type = string
    default = "default"
}
variable "default_tags" {
    type = map(string)
    default = {}
}

# VPC Flow Logs
#variable "traffic_type" {
#    type = string
#    default = "ALL"
#}
#variable "retention_in_days" {
#    type = number
#    default = 3
#}
variable "flow_log" {
    type    = list(map(string))
    default = []
}   

# VPC DHCP Options Set
variable "domain_name_servers" {
    type = string
    default = "AmazonProvidedDNS"
}

# VPC Subnets
variable "map_public_ip_on_launch" {
    type = bool
    default = false
}
variable "map_public_ip_on_launch_sn_pub" {
    type = bool
    default = true
}
#variable "newbits" {
#    type    = number
#}
variable "subnet_priv_block" {
    type    = string
}   
variable "subnet_pub_block" {
    type    = string
}   
