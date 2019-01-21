
module "security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  #version     = "2.7.0"

  name        = "web-sg"
  description = "web sg"
  vpc_id 	  = "${aws_vpc.terraformtraining.id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]

  egress_rules        = ["all-all"]
}

data "template_file" "httpd" {
  template = "${file("httpd.tpl")}"  
}

module "ec2_cluster1" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  name                   = "my-cluster1"
  instance_count         = 1
  # ami                    = "${data.aws_ami.amazon_linux.id}"
  ami                    = "ami-0080e4c5bc078760e"
  instance_type          = "t2.micro"
  key_name               = "celeghin"
  monitoring             = true
  vpc_security_group_ids = ["${module.security_group.this_security_group_id}"]
  #subnet_id              = "${element(aws_subnet.public_subnet.*.id, 0)}"
  subnet_id = "${aws_subnet.terraformtraining-public-1.id}"

  user_data              = "${data.template_file.httpd.rendered}"
  associate_public_ip_address = "true"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "ec2_cluster2" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  name                   = "my-cluster2"
  instance_count         = 1
  # ami                    = "${data.aws_ami.amazon_linux.id}"
  ami                    = "ami-0080e4c5bc078760e"
  instance_type          = "t2.micro"
  key_name               = "celeghin"
  monitoring             = true
  vpc_security_group_ids = ["${module.security_group.this_security_group_id}"]
  #subnet_id              = "${element(aws_subnet.public_subnet.*.id, 0)}"
  subnet_id = "${aws_subnet.terraformtraining-public-2.id}"

  user_data              = "${data.template_file.httpd.rendered}"
  associate_public_ip_address = "true"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_alb_target_group" "alb_front_http" {
  name     = "elb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id 	  = "${aws_vpc.terraformtraining.id}"
}

resource "aws_alb_target_group_attachment" "alb_backend-01_http" {
  target_group_arn = "${aws_alb_target_group.alb_front_http.arn}"
  target_id        = "${module.ec2_cluster1.id[0]}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "alb_backend-02_http" {
  target_group_arn = "${aws_alb_target_group.alb_front_http.arn}"
  target_id        = "${module.ec2_cluster2.id[0]}"
  port             = 80
}

module "elb_sg" {
  source      = "terraform-aws-modules/security-group/aws"

  name        = "elb-sg"
  description = "elb sg"
  vpc_id 	  = "${aws_vpc.terraformtraining.id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_front_http.arn}"
    type = "forward"
  }
}

resource "aws_alb" "alb" {
  name               = "myloadbalance"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${module.elb_sg.this_security_group_id}"]
  subnets            = ["${aws_subnet.terraformtraining-public-1.*.id}","${aws_subnet.terraformtraining-public-2.*.id}"]

  enable_deletion_protection = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
