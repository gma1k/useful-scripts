#!/usr/bin/env python3
# Usage: sudo python3 dns_flood_test.py --target 192.0.2.1 --count 200 --rate 100

from scapy.all import IP, UDP, DNS, DNSQR, send
import time
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--target", required=True, help="Target DNS server IP (use test server)")
parser.add_argument("--count", type=int, default=100, help="Number of queries to send")
parser.add_argument("--rate", type=float, default=50.0, help="Packets/sec (approx)")
parser.add_argument("--qname", default="example.com", help="Query name")
args = parser.parse_args()

interval = 1.0 / args.rate if args.rate > 0 else 0

payload = DNS(rd=1, qd=DNSQR(qname=args.qname))
ip = IP(dst=args.target)
udp = UDP(dport=53)

print(f"Sending {args.count} DNS queries to {args.target} at ~{args.rate} pkt/s")
for i in range(args.count):
    pkt = ip/udp/payload
    send(pkt, verbose=False)
    time.sleep(interval)

print("Done")
