data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user-data.sh")}"

  vars {
    vpc_dns_server = "${var.vpc_dns_server}"

    forward_zones_config  = "${join("\n", data.template_file.forward_zones.*.rendered)}"
    manual_records_config = "${join("\n", formatlist("local-data: \"%s\"", var.manual_records))}"
  }
}

data "template_file" "forward_zones" {
  count = "${length(var.search_domains)}"

  template = <<EOF
forward-zone:
    name: "$${onprem_domain}"
$${dns_servers}

EOF

  vars {
    onprem_domain = "${element(var.search_domains, count.index)}"
    dns_servers   = "${join("\n", formatlist("    forward-addr: %s", var.onprem_dns_servers))}"
  }
}
