#!/bin/bash

# Create limits groups
sudo cgcreate -g cpu,memory:/monitoring/grafana
sudo cgcreate -g cpu,memory:/monitoring/prometheus
sudo cgcreate -g cpu,memory:/monitoring/node_exporter
sudo cgcreate -g cpu,memory:/monitoring/alloy
sudo cgcreate -g cpu,memory:/monitoring/beyla
sudo cgcreate -g cpu,memory:/monitoring/loki
sudo cgcreate -g cpu,memory:/monitoring/promtail
sudo cgcreate -g cpu,memory:/monitoring/otelcol
sudo cgcreate -g cpu,memory:/monitoring/alertmanager

# Set memory and CPU limits for Grafana
echo 268435456 | sudo tee /sys/fs/cgroup/monitoring/grafana/memory.max
echo "50000 100000" | sudo tee /sys/fs/cgroup/monitoring/grafana/cpu.max

# Set memory and CPU limits for Prometheus
echo 536870912 | sudo tee /sys/fs/cgroup/monitoring/prometheus/memory.max
echo "100000 100000" | sudo tee /sys/fs/cgroup/monitoring/prometheus/cpu.max

# Set memory and CPU limits for Node Exporter
echo 67108864 | sudo tee /sys/fs/cgroup/monitoring/node_exporter/memory.max
echo "20000 100000" | sudo tee /sys/fs/cgroup/monitoring/node_exporter/cpu.max

# Set memory and CPU limits for Alloy
echo 134217728 | sudo tee /sys/fs/cgroup/monitoring/alloy/memory.max
echo "50000 100000" | sudo tee /sys/fs/cgroup/monitoring/alloy/cpu.max

# Set memory and CPU limits for Beyla
echo 268435456 | sudo tee /sys/fs/cgroup/monitoring/beyla/memory.max
echo "50000 100000" | sudo tee /sys/fs/cgroup/monitoring/beyla/cpu.max

# Set memory and CPU limits for Loki
echo 268435456 | sudo tee /sys/fs/cgroup/monitoring/loki/memory.max
echo "50000 100000" | sudo tee /sys/fs/cgroup/monitoring/loki/cpu.max

# Set memory and CPU limits for Promtail
echo 134217728 | sudo tee /sys/fs/cgroup/monitoring/promtail/memory.max
echo "20000 100000" | sudo tee /sys/fs/cgroup/monitoring/promtail/cpu.max

# Set memory and CPU limits for Otelcol
echo 268435456 | sudo tee /sys/fs/cgroup/monitoring/otelcol/memory.max
echo "50000 100000" | sudo tee /sys/fs/cgroup/monitoring/otelcol/cpu.max

# Set memory and CPU limits for Alertmanager
echo 134217728 | sudo tee /sys/fs/cgroup/monitoring/alertmanager/memory.max
echo "20000 100000" | sudo tee /sys/fs/cgroup/monitoring/alertmanager/cpu.max

# Assign processes to their respective cgroups
echo $(pgrep grafana) | sudo tee /sys/fs/cgroup/monitoring/grafana/cgroup.procs
echo $(pgrep prometheus) | sudo tee /sys/fs/cgroup/monitoring/prometheus/cgroup.procs
echo $(pgrep node_exporter) | sudo tee /sys/fs/cgroup/monitoring/node_exporter/cgroup.procs
echo $(pgrep alloy) | sudo tee /sys/fs/cgroup/monitoring/alloy/cgroup.procs
echo $(pgrep beyla) | sudo tee /sys/fs/cgroup/monitoring/beyla/cgroup.procs
echo $(pgrep loki) | sudo tee /sys/fs/cgroup/monitoring/loki/cgroup.procs
echo $(pgrep promtail) | sudo tee /sys/fs/cgroup/monitoring/promtail/cgroup.procs
echo $(pgrep otelcol) | sudo tee /sys/fs/cgroup/monitoring/otelcol/cgroup.procs
echo $(pgrep alertmanager) | sudo tee /sys/fs/cgroup/monitoring/alertmanager/cgroup.procs
