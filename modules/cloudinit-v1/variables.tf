variable "vpc_dns_server" {
  description = "VPC Nameserver to forward non-private queries to"
}

variable "search_domains" {
  description = "Domains to route to on-premises DNS such as (mycompany.net)"
  type        = "list"
}

variable "onprem_dns_servers" {
  description = "IPs of on-premises DNS servers"
  type        = "list"
}

variable "manual_records" {
  description = "List of manual static DNS A records passed to unbound local-data"
  type        = "list"
}
