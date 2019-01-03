locals {
  max_subnet_length = "${max(length(var.private_subnet_list))}"
  vpc_id = "${aws_vpc.vpc.id}"
}

provider "aws" {
  region = "${var.aws_region}"
  shared_credentials_file = "~/.aws/credentials"
  profile = "default"
}

resource "aws_vpc" "vpc" {
  cidr_block  = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.vpc_name}"
  }
}

################
# Private subnet
################
resource "aws_subnet" "private_subnet" {
  count = "${length(var.private_subnet_list) > 0 ? length(var.private_subnet_list) : 0}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.private_subnet_list[count.index]}"
  availability_zone = "${element(var.az_list, count.index)}"
  tags = "${merge(map("Name", format("%s-${var.private_subnet_suffix}", element(var.az_list, count.index))))}"
}

#################
# Private routes
#################
resource "aws_route_table" "private" {
  count = "${local.max_subnet_length}"
  vpc_id = "${local.vpc_id}"
  tags = "${merge(map("Name", format("%s-${var.private_subnet_suffix}", element(var.az_list, count.index))))}"
}

###################################
# Private Route table association
###################################
resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnet_list)}"
  subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, (var.single_nat_gateway ? 0 : count.index))}"
}

################
# Public subnet
################
resource "aws_subnet" "public_subnet" {
  count = "${length(var.public_subnet_list) > 0 ? length(var.public_subnet_list) : 0}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.public_subnet_list[count.index]}"
  availability_zone = "${element(var.az_list, count.index)}"
  tags = "${merge(map("Name", format("%s-${var.public_subnet_suffix}", element(var.az_list, count.index))))}"
}

#################
# Public routes
#################
resource "aws_route_table" "public" {
#  count = "${length(var.public_subnet_list) > 0 ? 1 : 0}"
  count = "${local.max_subnet_length}"
  vpc_id = "${local.vpc_id}"
  tags = "${merge(map("Name", format("%s-${var.public_subnet_suffix}", element(var.az_list, count.index))))}"
}

resource "aws_route" "public_internet_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  count = "${local.max_subnet_length}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
  gateway_id = "${aws_internet_gateway.public.id}"

  timeouts {
    create = "5m"
  }
}

###################################
# Public Route table association
###################################
resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnet_list)}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, (var.single_nat_gateway ? 0 : count.index))}"
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "public" {
  vpc_id = "${local.vpc_id}"
  tags {
    Name = "${var.aws_region}-${var.public_subnet_suffix}"
  }
}

