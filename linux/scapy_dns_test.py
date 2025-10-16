#!/usr/bin/env python3
# Usage: sudo python3 scapy_dns_test.py 8.8.8.8

from scapy.all import IP, UDP, DNS, DNSQR, send
import sys

if len(sys.argv) < 2:
    print("Usage: sudo python3 scapy_dns_test.py <target_ip>")
    sys.exit(1)

target = sys.argv[1]
pkt = IP(dst=target)/UDP(dport=53)/DNS(rd=1,qd=DNSQR(qname="example.com"))
for i in range(5):
    send(pkt, verbose=False)
print("sent 5 test DNS UDP packets to", target)
