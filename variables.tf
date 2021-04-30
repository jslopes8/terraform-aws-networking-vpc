variable "create" {
    type    = bool 
    default = true
}
variable "vpc_name" {
    type    = string
}
variable "region" {
    type = string
    default = "us-east-1"
}
variable "cidr_block" {
    type = string
    default = "0.0.0.0/0"
}
variable "enable_dns_hostnames" {
    type    = bool 
    default = false
}
variable "enable_dns_support" {
    type    = bool 
    default = false
}
variable "instance_tenancy" {
    type    = string
    default = "default"
}
variable "enable_classiclink" {
    type    = bool 
    default = false
}
variable "enable_classiclink_dns_support" {
    type    = bool 
    default = false
}
variable "assign_generated_ipv6_cidr_block" {
    type    = bool 
    default = false
}
variable "subnet_private" {
    type    = any 
    default = []
}
variable "subnet_public" {
    type    = any 
    default = []
}
variable "tag_public" {
    type = map(string)
    default = {}
}
variable "tag_private" {
    type = map(string)
    default = {}
}
variable "enable_nat_gateway" {
    type = bool  
    default = false
}
variable "dhcp_opts" {
    type = any 
    default = []
}
variable "default_tags" {
    type = map(string)
    default = {}
}
variable "flow_logs" {
    type = any
    default = {}
}
variable "subnet_database" {
    type = any 
    default = []
}
variable "subnet_cache" {
    type = any
    default = []
}
variable "vpc_peering_connection" {
    type = any
    default = []
}
variable "vpn_customer_gateway" {
    type = any
    default = []
}
