#!/bin/bash
set -eu

# Stop monitoring services
sudo systemctl stop grafana
sudo systemctl stop prometheus
sudo systemctl stop node_exporter
sudo systemctl stop alloy
sudo systemctl stop beyla
sudo systemctl stop loki
sudo systemctl stop promtail
sudo systemctl stop otelcol
sudo systemctl stop alertmanager

# sleep 5

# Reboot the system
# sudo reboot
