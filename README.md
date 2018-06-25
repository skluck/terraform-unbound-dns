# Terraform Module - Unbound DNS

> How to forward VPC traffic to a private (most likely on-premises) DNS server behind your firewall?

See also: [AWS Security Blog: How to Set Up DNS Resolution Between On-Premises Networks and AWS by Using Unbound](https://aws.amazon.com/blogs/security/how-to-set-up-dns-resolution-between-on-premises-networks-and-aws-by-using-unbound/)

#### Resources created by this module

1. Private EC2 instance with [unbound](https://www.unbound.net) installed (Supports multiple instances/AZs).
2. Attach refreshly created DNS server to VPC DHCP options.
3. Route one or more domains to private DNS.
4. Route all other requests to VPC DNS provided by AWS.
5. Allow static routes to be defined.
