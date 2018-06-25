data "template_file" "output" {
  template = <<EOF

AWS DNS Servers:
$${aws_name_servers}

On-premises DNS Servers:
$${onprem_name_servers}

Domains: $${domain}
Manual Records:
    $${manual_records}
EOF

  vars {
    aws_name_servers    = "${join("\n", formatlist("    - %s", aws_instance.unbound.*.private_ip))}"
    onprem_name_servers = "${join("\n", formatlist("    - %s", var.onprem_dns_servers))}"

    domain         = "${join(", ", var.search_domains)}"
    manual_records = "${join("\n", formatlist("    - %s", var.onprem_dns_records))}"
  }
}

output "success_message" {
  value = "${data.template_file.output.rendered}"
}
