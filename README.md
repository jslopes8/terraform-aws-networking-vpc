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
  source = "git@github.com:jslopes8/terraform-aws-vpc.git?ref=v2.4"

  vpc_name		= "vpc-test"
  region 		= "us-east-1"
  cidr_block	= "10.0.0.0/16"
	
}
```
Exemplo de uso: Criando uma VPC com uma subnet publica.
```hcl
module "vpc" {
  source = "git@github.com:jslopes8/terraform-aws-vpc.git?ref=v2.4"

  vpc_name    	= "vpc-test"
  region 	= "us-east-1"
  cidr_block  	= "10.0.0.0/16"
  
  subnet_public = [
  	{
		tag_name		= "vpc-pub-1a"
		cidr_block 		= "10.0.0.0/19"
		availability_zone 	= "us-east-1a"
		map_public_ip_on_launch	= "true"
	}
  ]
}
```
Exemplo de uso: Criando uma VPC com duas subnet publicas em duas AZs.
```hcl
module "vpc" {
  source = "git@github.com:jslopes8/terraform-aws-vpc.git?ref=v2.0"

  vpc_name    	= "vpc-test"
  region 	= "us-east-1"
  cidr_block  	= "10.0.0.0/16"
  
  subnet_public = [
  	{
		tag_name		= "vpc-pub-1a"
		cidr_block 		= "10.0.0.0/19"
		availability_zone 	= "us-east-1a"
		map_public_ip_on_launch	= "true"
	},
  	{
		tag_name		= "vpc-pub-1b"
		cidr_block 		= "10.0.64.0/18"
		availability_zone 	= "us-east-1b"
		map_public_ip_on_launch	= "true"
	}
  ]
}
```
Exemplo de uso: Criando uma VPC com três subnet publicas em duas AZs.
```hcl
module "vpc" {
  source = "git@github.com:jslopes8/terraform-aws-vpc.git?ref=v2.0"

  vpc_name    	= "vpc-test"
  region 	= "us-east-1"
  cidr_block  	= "10.0.0.0/16"
  
  subnet_public = [
  	{
		tag_name		= "vpc-pub-1a"
		cidr_block 		= "10.0.0.0/19"
		availability_zone 	= "us-east-1a"
		map_public_ip_on_launch	= "true"
	},
  	{
		tag_name		= "vpc-pub-1b"
		cidr_block 		= "10.0.64.0/18"
		availability_zone 	= "us-east-1b"
		map_public_ip_on_launch	= "true"
	},
  	{
		tag_name		= "vpc-pub-1c"
		cidr_block 		= "10.0.128.0/18"
		availability_zone 	= "us-east-1c"
		map_public_ip_on_launch	= "true"
	}
  ]
}
```

Exemplo de uso: Criando uma VPC Completa com duas Subnet Publicas e duas subnet Privadas

```hcl
module "create_vpc" {
  source = "git@github.com:jslopes8/terraform-aws-vpc.git?ref=v2.4"

  vpc_name    		= local.vpc_name
  region 			= "us-east-1"
  cidr_block  		= "10.0.0.0/16"
  enable_dns_hostnames 	= "true"
  enable_dns_support   	= "true"
  
  dhcp_opts = [{
	domain_name_servers = [ "AmazonProvidedDNS" ]
   }]
   enable_nat_gateway = "true"
   subnet_public = [
   	{
		tag_name		= "${local.vpc_name}-pub-1a"
		cidr_block 		= "10.0.0.0/18"
		availability_zone 	= "us-east-1a"
		map_public_ip_on_launch	= "true"
    	},
    	{
		tag_name		= "${local.vpc_name}-pub-1b"
		cidr_block 		= "10.0.64.0/18"
		availability_zone 	= "us-east-1b"
		map_public_ip_on_launch	= "true"
    	}
    ]
    subnet_private = [
        {
		tag_name		= "${local.vpc_name}-priv-1a"
		cidr_block 		= "10.0.128.0/18"
		availability_zone 	= "us-east-1a"
    	},
        {
		tag_name		= "${local.vpc_name}-priv-1b"
		cidr_block 		= "10.0.192.0/18"
		availability_zone 	= "us-east-1b"
    	}
  	]
	
    default_tags = local.default_tags
}
```

Exemplo de uso: Criando uma VPC para Cluster EKS.

```hcl
module "create_vpc" {
  source = "git@github.com:jslopes8/terraform-aws-vpc.git?ref=v2.4"

  vpc_name    			= local.vpc_name
  
  --- omitido trechos ---
  
  enable_nat_gateway = "true"
  subnet_public = [
  	{
		tag_name		= "${local.vpc_name}-Pub-1a"
		cidr_block 		= "10.0.0.0/18"
		availability_zone 	= "us-east-1a"
		map_public_ip_on_launch	= "true"
		tag_public		= {
			"kubernetes.io/role/elb"			= "1"
			"kubernetes.io/cluster/${local.cluster_name}" 	= "shared"
		}
    	},
    	{
		tag_name		= "${local.vpc_name}-Pub-1b"
		cidr_block 		= "10.0.64.0/18"
		availability_zone 	= "us-east-1b"
		map_public_ip_on_launch	= "true"
		tag_public		= {
			"kubernetes.io/role/elb"			= "1"
			"kubernetes.io/cluster/${local.cluster_name}" 	= "shared"
		}
    	}
    ]
     
    subnet_private = [
        {
		tag_name		= "${local.vpc_name}-Priv-1a"
		cidr_block 		= "10.0.128.0/18"
		availability_zone 	= "us-east-1a"
		tag_private		= {
			"kubernetes.io/role/internal-elb"		= "1"
			"kubernetes.io/cluster/${local.cluster_name}" 	= "shared"
		}
    	},
        {
		tag_name		= "${local.vpc_name}-Priv-1b"
		cidr_block 		= "10.0.192.0/18"
		availability_zone 	= "us-east-1b"
		tag_private		= {
			"kubernetes.io/role/internal-elb"		= "1"
			"kubernetes.io/cluster/${local.cluster_name}" 	= "shared"
		}
    	}
  ]
  
  --- omitido trechos ---

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
| enable_dns_hostnames | Suporte a hostname de DNS na VPC. | `no` | `bool` | `false` |
| enable_dns_support | Suporte a DNS na VPC. | `no` | `bool` | `false` |
| dhcp_opts | Block de chave-valor que fornece um recurso de opções VPC DHCP. | `no` | `map` | `{ }` |
| enable_nat_gateway | Quando habilitado, fornece um recurso de NAT Gateway, em conjundo com o Elastic IP. A quantidade de criação deste recurso vai de acordo com o numero de subnet criada. (importante, use quando tiver criando uma VPC com subnet publica e privada). | `no` | `bool` | `false` |
| subnet_public | Block para criação da sua subnet publica. Detalhes logo abaixo. | `no` | `list` | `[ ]` |
| subnet_private | Block para criação da sua subnet privada. Detalhes logo abaixo. | `no` | `list` | `[ ]` |
| default_tags | Block de chave-valor que fornece o taggeamento para todos os recursos criados em sua VPC. | `no` | `map` | `{}` |
| cidr_block | O bloco de CIDR para a sua VPC | `yes` | `string` | ` ` |
| subnet_database | Block para criação de uma subnet para seus database . Detalhes logo abaixo. | `no` | `list` | `[ ]` |
| subnet_cache | Block para criação de uma subnet para os elasticache . Detalhes logo abaixo. | `no` | `list` | `[ ]` |
| flow_logs | Registro de fluxo de uma VPC/Subnet/ENI para capturar um trafego de IP para uma interface de rede. Logs serão enviado para o CloudWatch Logs Group. | `no` | `list` | `[ ]` | 
| vpc_peering_connection | Fornece um recurso para criar uma conexão de VPC Peering VPC-to-VPC na mesma conta. Para VPC Peering entre contas diferentes, consulte [test](test) | `no` | `list` | `[ ]` |

O argumento `subnet_public` possui os seguintes atributos;

- `tag_name`: O nome da sua subnet.
- `cidr_block`: O CIDR da sua subnet.
- `availability_zone`: Qual AZ será criada a sua subnet.
- `map_public_ip_on_launch`: Permite que as instâncias iniciadas na subnet podem receber um endereço IP público.
- `tag_public`: Um mapa de tags exclusiva para a sua subnet.

O argumento `subnet_private` possui os seguintes atributos;

- `tag_name`: O nome da sua subnet.
- `cidr_block`: O CIDR da sua subnet.
- `availability_zone`: Qual AZ será criada a sua subnet.
- `tag_private`: Um mapa de tags exclusiva para a sua subnet.

O argumento `dhcp_opts` possui os seguintes atributos;

- `domain_name`: O nome do domínio de sufixo a ser usado para resolver nomes FQDN. 
- `domain_name_servers`: Lista de servidores de nomes para configurar /etc/resolv.conf.

O argumento `flow_logs` possui os seguintes atributos;

- `traffic_type`: O tipo de tráfego a ser capturado. Valores válidos: ACCEPT, REJECT, ALL.
- `log_format`: Os campos a serem incluídos no registro do log de fluxo, na ordem em que devem aparecer
- `retention_in_days`: Retenção dos logs em dias.

O argumento `vpc_peering_connection` possui os seguintes atributos;

- `accepter_vpc_id`: O ID do VPC com o qual você está criando uma conexão de VPC Peering.
- `accepter_vpc_region`: A região da VPC do aceitante. Valores validos: true, false.
- `auto_accept`: Aceitar ou não a solicitação de peering. O padrão é false.

## Variable Outputs
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
| Name | Description |
| ---- | ----------- |
| vpc | O ID da VPC criada |
| subnet_private | O CIDR da subnet privada criada |
| subnet_private_id | O Id da subnet privada criada |
| subnet_public | O CIDR da subnet publica criada |
| subnet_public_id | O Id da subnet publica criada |
| elastic_ip | O IP alocado para o seu elastic ip |
| vpc_peering_id | O Id da conexão da VPC Peering |
| rt_private_id | O Id da tabela de roteamento da sua rede privada |
| rt_public_id | O Id da tabela de roteamento da sua rede publica |
