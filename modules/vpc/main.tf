data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = var.enable_dns
  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_subnet" "public" {
  count                   = local.pub_subnet_count > 0 ? local.pub_subnet_count : 0
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = true
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-${count.index}"
    }
  )
}

resource "aws_subnet" "private" {
  count             = local.priv_subnet_count > 0 ? local.priv_subnet_count : 0
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.this.id
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-${count.index}"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-internet-gateway"
    }
  )
}

resource "aws_route_table" "public" {
  count  = local.pub_subnet_count > 0 ? local.pub_subnet_count : 0
  vpc_id = aws_vpc.this.id
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-route-table-public-${count.index}"
    }
  )
  route {
    cidr_block = local.all_ips
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "public" {
  count          = local.pub_subnet_count > 0 ? local.pub_subnet_count : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_eip" "nat_gateway" {
  count      = local.priv_subnet_count > 0 ? local.priv_subnet_count : 0
  vpc        = true
  depends_on = [aws_internet_gateway.this]
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-eip-${count.index}"
    }
  )
}

resource "aws_nat_gateway" "public" {
  count         = local.priv_subnet_count > 0 ? local.priv_subnet_count : 0
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat_gateway[count.index].id
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-gateway-${count.index}"
    }
  )
}

resource "aws_route_table" "private" {
  count  = local.priv_subnet_count > 0 ? local.priv_subnet_count : 0
  vpc_id = aws_vpc.this.id
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-route-table-private-${count.index}"
    }
  )

  route {
    cidr_block     = local.all_ips
    nat_gateway_id = aws_nat_gateway.public[count.index].id
  }
}

resource "aws_route_table_association" "private" {
  count          = local.priv_subnet_count > 0 ? local.priv_subnet_count : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
