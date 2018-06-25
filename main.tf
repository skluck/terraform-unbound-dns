provider "aws" {
  region = "${var.aws_region}"
}

# ----------------------------------------------------------------------------------------------------------------------
# local vars
# ----------------------------------------------------------------------------------------------------------------------

locals {
  iac_tags = {
    Name = "${var.prefix}-dns-forwarder"
    iac = "terraform"
  }
}

data "aws_ami" "default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

data "aws_subnet" "selected" {
  count = "${length(var.subnet_ids)}"
  id    = "${element(var.subnet_ids, count.index)}"
}

# ----------------------------------------------------------------------------------------------------------------------
# security groups
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "unbound_sg" {
  name        = "${var.prefix}-dns-forwarder"
  description = "Allow DNS to Unbound host from approved ranges"

  vpc_id = "${data.aws_vpc.selected.id}"

  tags = "${merge(
    var.iac_tags,
    local.iac_tags
  )}"
}

resource "aws_security_group_rule" "dns_ingress_udp_53" {
  type      = "ingress"
  protocol  = "udp"
  from_port = 53
  to_port   = 53

  cidr_blocks       = ["${data.aws_vpc.selected.cidr_block}"]
  security_group_id = "${aws_security_group.unbound_sg.id}"
}

resource "aws_security_group_rule" "dns_ingress_tcp_53" {
  type      = "ingress"
  protocol  = "tcp"
  from_port = 53
  to_port   = 53

  cidr_blocks       = ["${data.aws_vpc.selected.cidr_block}"]
  security_group_id = "${aws_security_group.unbound_sg.id}"
}

resource "aws_security_group_rule" "dns_egress" {
  type      = "egress"
  protocol  = "-1"
  from_port = 0
  to_port   = 0

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.unbound_sg.id}"
}

# ----------------------------------------------------------------------------------------------------------------------
# launch config
# ----------------------------------------------------------------------------------------------------------------------

module "cloudinit" {
  source = "./modules/cloudinit-v1"

  vpc_dns_server = "${cidrhost(data.aws_vpc.selected.cidr_block, 2)}"

  search_domains     = ["${var.search_domains}"]
  onprem_dns_servers = ["${var.onprem_dns_servers}"]
  manual_records     = ["${var.onprem_dns_records}"]
}

# ----------------------------------------------------------------------------------------------------------------------
# instances
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "unbound" {
  count = "${length(var.subnet_ids)}"

  instance_type = "${var.instance_type}"
  ami           = "${data.aws_ami.default.id}"
  key_name      = "${var.keypair}"

  associate_public_ip_address = false
  disable_api_termination     = false

  vpc_security_group_ids  = ["${aws_security_group.unbound_sg.id}"]
  subnet_id               = "${data.aws_subnet.selected.*.id[count.index]}"
  user_data               = "${module.cloudinit.rendered}"

  tags = "${merge(
    var.iac_tags,
    local.iac_tags
  )}"

  volume_tags = "${merge(
    var.iac_tags,
    local.iac_tags
  )}"
}

# ----------------------------------------------------------------------------------------------------------------------
# vpc - dhcp options
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["${aws_instance.unbound.*.private_ip}"]

  tags = "${merge(
    var.iac_tags,
    local.iac_tags
  )}"
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${data.aws_vpc.selected.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}
