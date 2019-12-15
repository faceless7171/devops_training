resource "aws_route_table" "main" {
  vpc_id = var.vpc_id

  route {
    cidr_block  = var.cidr_block
    gateway_id  = var.gateway_id
    instance_id = var.instance_id
  }

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_route_table_association" "all" {
  count = length(var.associations_subnet_ids)

  subnet_id      = var.associations_subnet_ids[count.index]
  route_table_id = aws_route_table.main.id
}
