#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, HTTPServer
import os

class MetricsHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        with open('/var/www/html/metrics/speedtest.prom', 'r') as f:
            self.wfile.write(f.read().encode())

def run(server_class=HTTPServer, handler_class=MetricsHandler, port=9100):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f'Serving metrics on port {port}...')
    httpd.serve_forever()

if __name__ == '__main__':
    run()
