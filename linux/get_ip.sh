#!/bin/bash

ETH0_IP=$(ip a show eth0 | sed -ne '/inet 172\.18\.0/ s/.*inet \(172\.18\.0\.[0-9]\+\).*/\1/p')
echo $ETH0_IP
