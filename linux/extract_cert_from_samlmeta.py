#!/usr/bin/env python3

"""
  Extract X.509 Certificate from SAML metadata, usually embedded in a
  XML file.
  And print the certificate in ascii PEM format.
"""

import sys
import re
import os
import xml.etree.ElementTree as ET
from cryptography import x509
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

# XML Signature namespace
namespaces = {'ds': 'http://www.w3.org/2000/09/xmldsig#'}


def parsexml(xmlfile=None):
    certificate = ''

    fh = open(xmlfile)

    # Parse XML file
    tree = ET.parse(fh)

    # Search for embedded X.509 certificate
    for elem in tree.iterfind('.//ds:X509Certificate', namespaces):
        if elem.text:
            # Found certificate, add pem begin/end tags
            certificate = '-----BEGIN CERTIFICATE-----\n' + \
                          elem.text + \
                          '\n-----END CERTIFICATE-----'
            break

    if certificate:
        try:
            # Create X.509 Certificate Object
            cert = x509.load_pem_x509_certificate(
                   data=certificate.encode('ascii'),
                   backend=default_backend())
        except ValueError:
            print('Unable to load certificate.')
            sys.exit(3)

        if cert.version:
            print(f'Issuer: {cert.issuer}')
            print(f'Subject: {cert.subject}')
            print(f'Not valid before: {cert.not_valid_before}')
            print(f'Not valid after: {cert.not_valid_after}')
            # Print ascii PEM
            print(cert.public_bytes(
                  serialization.Encoding.PEM)
                  .decode('ascii'), end='')

    # Close file and in case of a tempfile, delete it.
    fh.close()

def main():
    # Check arguments
    if len(sys.argv) == 2:
        param = sys.argv[1]

        # Read XML file from web location
        if re.match(r'^http[s]?://\w+', param):
            import requests
            import tempfile
            try:
                resp = requests.get(param)
                tf = tempfile.NamedTemporaryFile()
                with open(tf.name, 'wb') as f:
                    f.write(resp.content)
            except Exception:
                print('Can\'t read file')
                sys.exit(1)

            parsexml(xmlfile=tf.name)

        # Read XML file from disk
        elif os.access(param, os.R_OK):
            try:
                parsexml(xmlfile=param)
            except Exception:
                print('Can\'t read file.')
                sys.exit(2)
        else:
            syntax()
    else:
        syntax()

def syntax():
    print(f'''syntax: {sys.argv[0]} [FILE|URL]

FILE  XML file
URL   XML file from web location''')

if __name__ == "__main__":
    main()
