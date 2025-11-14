#!/usr/bin/env python3

from scapy.all import sniff, DNS, DNSQR, IP, get_if_list
import sys

def detect_iface():
    interfaces = get_if_list()

    if not interfaces:
        print("Error: No network interfaces found.")
        sys.exit(1)

    for iface in interfaces:
        if iface != "lo":
            return iface

    return interfaces[0]


iface = detect_iface()
print(f"[+] Listening for DNS traffic on {iface}")


def handle_packet(pkt):
    if pkt.haslayer(DNS) and pkt.haslayer(DNSQR):
        ip = pkt[IP].src if pkt.haslayer(IP) else "unknown"
        dns = pkt[DNS]
        q = dns[DNSQR]
        qname = q.qname.decode(errors="ignore").rstrip(".")
        qtype = q.qtype

        qtype_map = {
            1: "A",
            28: "AAAA",
            5: "CNAME",
            12: "PTR",
            15: "MX",
            16: "TXT",
            6: "SOA",
        }
        qtype_str = qtype_map.get(qtype, str(qtype))

        print(f"[DNS] {ip} -> {qname} (QTYPE {qtype_str})")


if __name__ == "__main__":
    sniff(
        iface=iface,
        filter="udp port 53",
        prn=handle_packet,
        store=False
    )
