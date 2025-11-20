#!/usr/bin/env python3

from scapy.all import sniff, DNS, DNSQR, IP, get_working_ifaces
import sys

def detect_iface():
    active = get_working_ifaces()

    if not active:
        print("Error: No active network interfaces found.")
        sys.exit(1)

    for iface in active:
        if iface.name != "lo":
            print("Skipping loopback interface")
            return iface.name
    sys.exit(1)

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
        prn=handle_packet,
        store=False
    )
