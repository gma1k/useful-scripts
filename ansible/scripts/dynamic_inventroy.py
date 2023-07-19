#!/usr/bin/env python3

import json
import subprocess

network = "10.10.7.0/24"

nmap_cmd = f"nmap -oX - -p 22 {network}"
nmap_output = subprocess.check_output(nmap_cmd, shell=True)

hosts = []
for line in nmap_output.splitlines():
  line = line.decode("utf-8")
  if "<hostname name=" in line:
    hostname = line.split('"')[1]
  if "<address addr=" in line and "addrtype=\"ipv4\"" in line:
    ip_address = line.split('"')[1]
    hosts.append((hostname, ip_address))

inventory = {
  "sftp-server": {
    "hosts": [host[0] for host in hosts],
    "vars": {
      "ansible_ssh_private_key_file": "/path/to/private/key"
    }
  }
}

print(json.dumps(inventory))
