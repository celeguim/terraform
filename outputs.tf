
output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "private subnet" {
  value = "${formatlist("%v", aws_subnet.private_subnet.*.id)}"
}

output "public subnet" {
  value = "${formatlist("%v", aws_subnet.public_subnet.*.id)}"
}

output "private route" {
  value = "${formatlist("%v", aws_route_table.private.*.id)}"
}

output "public route" {
  value = "${formatlist("%v", aws_route_table.public.*.id)}"
}

output "ec2" {
  value = ["${module.ec2_cluster.id}","${module.ec2_cluster.public_ip}"]
}
