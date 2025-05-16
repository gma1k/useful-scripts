#!/usr/bin/env python3

# Usage Example: python3 port_scanner.py scanme.nmap.org --start 20 --end 100 --threads 30

import socket
import argparse
import threading
import logging
from queue import Queue
from typing import Optional

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
print_lock = threading.Lock()

BANNER_TIMEOUT = 2


def grab_banner(ip: str, port: int) -> Optional[str]:
    """
    Attempts to grab the service banner from an open port.

    Args:
        ip (str): IP address.
        port (int): TCP port.

    Returns:
        Optional[str]: The banner string if available.
    """
    try:
        with socket.socket() as s:
            s.settimeout(BANNER_TIMEOUT)
            s.connect((ip, port))
            try:
                return s.recv(1024).decode().strip()
            except socket.timeout:
                return None
    except Exception:
        return None


def scan_port(ip: str, port: int):
    """
    Attempts to connect to a port and prints if it's open.

    Args:
        ip (str): IP address.
        port (int): TCP port.
    """
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(1)
        try:
            s.connect((ip, port))
            with print_lock:
                print(f"[+] Port {port} is open", end="")
                banner = grab_banner(ip, port)
                if banner:
                    print(f" | Banner: {banner}")
                else:
                    print()
        except (socket.timeout, ConnectionRefusedError):
            pass


def thread_worker(ip: str, port_queue: Queue):
    while not port_queue.empty():
        port = port_queue.get()
        scan_port(ip, port)
        port_queue.task_done()


def run_scanner(ip: str, start_port: int, end_port: int, threads: int):
    port_queue = Queue()
    for port in range(start_port, end_port + 1):
        port_queue.put(port)

    thread_list = []
    for _ in range(threads):
        t = threading.Thread(target=thread_worker, args=(ip, port_queue))
        t.daemon = True
        t.start()
        thread_list.append(t)

    port_queue.join()
    for t in thread_list:
        t.join()


def resolve_target(target: str) -> str:
    """
    Resolves a hostname to an IP address.

    Args:
        target (str): Hostname or IP.

    Returns:
        str: IP address.
    """
    try:
        return socket.gethostbyname(target)
    except socket.gaierror:
        logging.error(f"Unable to resolve host: {target}")
        exit(1)


def main():
    parser = argparse.ArgumentParser(description="Simple TCP Port Scanner with Banner Grabbing")
    parser.add_argument("target", help="Target IP address or hostname")
    parser.add_argument("--start", type=int, default=1, help="Start port (default: 1)")
    parser.add_argument("--end", type=int, default=1024, help="End port (default: 1024)")
    parser.add_argument("--threads", type=int, default=50, help="Number of threads (default: 50)")

    args = parser.parse_args()

    ip = resolve_target(args.target)
    logging.info(f"Starting scan on {ip} from port {args.start} to {args.end} using {args.threads} threads")
    run_scanner(ip, args.start, args.end, args.threads)


if __name__ == "__main__":
    main()
