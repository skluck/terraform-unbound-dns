variable "aws_region" {
  description = "Region where resources get created"
}

variable "prefix" {
  description = "Prefix to add to resource names"
  default     = ""
}

variable "iac_tags" {
  type    = "map"
  default = {}
}

# ----------------------------------------------------------------------------------------------------------------------
# networking
# ----------------------------------------------------------------------------------------------------------------------

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

# ----------------------------------------------------------------------------------------------------------------------
# dns
# ----------------------------------------------------------------------------------------------------------------------

variable "search_domains" {
  description = "Domains to search to for non-fully-qualified DNs (['mycompany.net', 'private.example.com'])"
  type        = "list"
}

variable "onprem_dns_servers" {
  description = "IPs of on-premises DNS servers"
  type        = "list"
}

variable "onprem_dns_records" {
  description = "List of manual static DNS A records passed to unbound local-data"
  type        = "list"
  default     = []
}

# ----------------------------------------------------------------------------------------------------------------------
# instance
# ----------------------------------------------------------------------------------------------------------------------

variable "instance_type" {
  default = "t2.small"
}

variable "keypair" {
  default = ""
}
