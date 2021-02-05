resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  tags                 = local.common_tags
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "eks_vpc_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = local.common_tags
}

data "aws_availability_zones" "aws_availability_zones" {}


#count example
resource "aws_subnet" "eks_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone_id    = data.aws_availability_zones.aws_availability_zones.zone_ids[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    map(
      "Name", "eks_subnet_${count.index}",
      "kubernetes.io/role/elb", 1,
      "kubernetes.io/cluster/DevOps_bootcamp_demo", "shared"
    )
  )

}



resource "aws_route_table" "eks_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_vpc_igw.id
  }

  tags = local.common_tags
}


resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  vpc_id         = aws_vpc.eks_vpc.id
  route_table_id = aws_route_table.eks_route_table.id
}
