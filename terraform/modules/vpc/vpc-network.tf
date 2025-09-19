resource "aws_vpc" "vpc_network" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, { Name = var.name })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_network.id
  tags   = merge(var.tags, { Name = "${var.name}-igw" })
}

# Public subnets
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }

  vpc_id                  = aws_vpc.vpc_network.id
  cidr_block              = each.value
  availability_zone = length(var.azs) > 0 ? element(var.azs, each.key) : null
  map_public_ip_on_launch = true
  tags = merge(var.tags, { Name = "${var.name}-public-${each.key}" })
}

# Private subnets
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id            = aws_vpc.vpc_network.id
  cidr_block        = each.value
  availability_zone = length(var.azs) > 0 ? element(var.azs, each.key) : null
  tags = merge(var.tags, { Name = "${var.name}-private-${each.key}" })
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_network.id
  tags   = merge(var.tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "pub_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway(s) and Elastic IP(s) optional
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(aws_subnet.public) : 0
  tags  = merge(var.tags, { Name = "${var.name}-nat-eip-${count.index}" })
}

resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat_gateway ? length(aws_subnet.public) : 0
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags          = merge(var.tags, { Name = "${var.name}-nat-${count.index}" })
}

# Private route tables with NAT (first nat gw used then fallback)
resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.vpc_network.id
  tags     = merge(var.tags, { Name = "${var.name}-private-rt-${each.key}" })
}

resource "aws_route" "private_nat" {
  for_each               = aws_subnet.private
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.enable_nat_gateway ? aws_nat_gateway.nat[each.key].id : null
}

resource "aws_route_table_association" "priv_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
