#!/usr/bin/env python3
from scapy.all import sniff, DNS, DNSQR, IP
import sys

def detect_iface():
    if len(sys.argv) > 1:
        return sys.argv[1]
    # fall back to your known NIC
    return "enp4s0"

iface = detect_iface()
print(f"[+] Listening for DNS traffic on {iface} (UDP port 53)")

def handle_packet(pkt):
    # We only care about DNS queries over UDP/53
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
