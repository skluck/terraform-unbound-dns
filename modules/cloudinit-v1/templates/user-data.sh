#!/bin/bash

set -e
set -x
set -o pipefail
set -u

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

cat - >/etc/resolv.conf <<EOF
nameserver ${vpc_dns_server}

EOF

function banner()
{
    tracestate="$(shopt -po xtrace)"

    set +x
    echo "--------------------------------------------------------------------------------"
    echo "    $${1}"
    echo "--------------------------------------------------------------------------------"

    eval "$tracestate"
}

banner "Performing System Updates"

yum update -y && \
    yum install -y \
        unbound

sed -i '/interface: 0.0.0.0$/s/#//'                             /etc/unbound/unbound.conf
sed -i '/access-control: 0.0.0.0\/0 refuse$/s/#//'              /etc/unbound/unbound.conf
sed -i '/access-control: 0.0.0.0\/0 refuse$/s/refuse/allow/'    /etc/unbound/unbound.conf
sed -i '/val-permissive-mode: no$/s/no/yes/'                    /etc/unbound/unbound.conf

cat - >/etc/unbound/local.d/onprem-static.conf <<EOF
${manual_records_config}

EOF

cat - >/etc/unbound/conf.d/onprem-forward.conf <<EOF
${forward_zones_config}

forward-zone:
    name: "."
    forward-addr: ${vpc_dns_server}

EOF

banner "Starting Unbound"

service unbound start
chkconfig unbound on
service unbound status
