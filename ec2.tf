
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

module "security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  #version     = "2.7.0"

  name        = "web-sg"
  description = "Security group for example usage with EC2 instance"
  vpc_id 	  = "${local.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]

  egress_rules        = ["all-all"]
}

data "template_file" "httpd" {
  template = "${file("httpd.tpl")}"  
}

module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  name                   = "my-cluster"
  instance_count         = 1
  # ami                    = "${data.aws_ami.amazon_linux.id}"
  ami                    = "ami-0080e4c5bc078760e"
  instance_type          = "t2.micro"
  key_name               = "celeghin"
  monitoring             = true
  vpc_security_group_ids = ["${module.security_group.this_security_group_id}"]
  subnet_id              = "${element(aws_subnet.public_subnet.*.id, 0)}"
  user_data              = "${data.template_file.httpd.rendered}"
  associate_public_ip_address = "true"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


