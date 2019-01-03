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
  tags = "${merge(map("Name", format("%s-${var.private_subnet_suffix}-%s", var.vpc_name, element(var.az_list, count.index))), var.tags, var.private_subnet_tags)}"
}

################
# Public subnet
################
resource "aws_subnet" "public_subnet" {
  count = "${length(var.public_subnet_list) > 0 ? length(var.public_subnet_list) : 0}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.public_subnet_list[count.index]}"
  availability_zone = "${element(var.az_list, count.index)}"
  tags = "${merge(map("Name", format("%s-${var.public_subnet_suffix}-%s", var.vpc_name, element(var.az_list, count.index))), var.tags, var.public_subnet_tags)}"
}

#################
# Private routes
#################
resource "aws_route_table" "private" {
  count = "${local.max_subnet_length}"
  vpc_id = "${local.vpc_id}"
  tags = "${merge(map("Name", (var.single_nat_gateway ? "${var.vpc_name}-${var.private_subnet_suffix}" : format("%s-${var.private_subnet_suffix}-%s", var.vpc_name, element(var.az_list, count.index)))), var.tags, var.private_route_table_tags)}"
}
