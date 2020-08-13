# AWS VPC Terraform module

Terraform module irá provisionar os seguintes recursos:

O codigo irá prover os seguintes recursos na AWS.
* [VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)
* [VPC Flow Log](https://www.terraform.io/docs/providers/aws/r/flow_log.html)
* [CloudWatch Log](https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html)
* [Subnet](https://www.terraform.io/docs/providers/aws/r/subnet.html)
* [Route](https://www.terraform.io/docs/providers/aws/r/route.html)
* [Route table](https://www.terraform.io/docs/providers/aws/r/route_table.html)
* [Internet Gateway](https://www.terraform.io/docs/providers/aws/r/internet_gateway.html)
* [Network ACL](https://www.terraform.io/docs/providers/aws/r/network_acl.html)
* [NAT Gateway](https://www.terraform.io/docs/providers/aws/r/nat_gateway.html)
* [DHCP Options Set](https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options.html)
* [Default VPC](https://www.terraform.io/docs/providers/aws/r/default_vpc.html)
* [Default Network ACL](https://www.terraform.io/docs/providers/aws/r/default_network_acl.html)
* [Elastic IP](https://www.terraform.io/docs/providers/aws/r/eip.html)

Existem muitas ferramentas disponiveis para auxiliar-lo a calcular blocos CIDR da sua subnet, eu estou utilizando, por exemoplo, http://www.davidc.net/sites/default/subnets/subnets.html.


## Usage
Exemplo de uso: Criando uma VPC básica.
```hcl
module "vpc" {
  	source = "git@github.com:jslopes8/terraform-aws-vpc.git?ref=v2.0"

  	vpc_name    = "vpc-test"
	region 		= "us-east-1"
  	cidr_block  = "10.0.0.0/16"
	
}
```
Exemplo de uso: Criando uma VPC com uma subnet publica.
```hcl
module "vpc" {
  	source = "git@github.com:jslopes8/terraform-aws-vpc.git?ref=v2.0"

  	vpc_name    = "vpc-test"
	region 		= "us-east-1"
  	cidr_block  = "10.0.0.0/16"

	subnet_public = [
    	{
			tag_name				= "vpc-pub-1a"
			cidr_block 				= "10.0.0.0/19"
			availability_zone 		= "us-east-1a"
			map_public_ip_on_launch	= "true"
    	}
	]
}
```
Exemplo de uso: Criando uma VPC com subnet em duas AZs.
```hcl
module "vpc" {
  	source = "git@github.com:jslopes8/terraform-aws-vpc.git?ref=v2.0"

  	vpc_name    = "vpc-test"
	region 		= "us-east-1"
  	cidr_block  = "10.0.0.0/16"

	subnet_public = [
    	{
			tag_name            = "vpc-pub-1a"
			cidr_block 	        = "10.0.0.0/19"
			availability_zone 	= "us-east-1a"
			map_public_ip_on_launch	= "true"
    	},
    	{
			tag_name			= "vpc-pub-1b"
			cidr_block 			= "10.0.64.0/18"
			availability_zone 	= "us-east-1b"
			map_public_ip_on_launch	= "true"
    	}
	]
}
```
## Requirements
| Name | Version |
| ---- | ------- |
| aws | ~> 3.1 |
| terraform | ~> 0.12 |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Variables Inputs
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| vpc_name | O nome da sua VPC | `yes` | `string` | ` ` |
| region | Escolha qual região está criando a sua VPC | `no` | `string` | `us-east-1` |

## Variable Outputs
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
| Name | Description |
| ---- | ----------- |
| vpc | O ID da VPC criada |