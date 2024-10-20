#!/bin/bash
set -eu

# Define the Prometheus metrics as variables
DOWNLOAD_METRIC="speedtest_download_mbps"
UPLOAD_METRIC="speedtest_upload_mbps"
PING_METRIC="speedtest_ping_latency_ms"

# Run Speedtest and get results in JSON format
run_speedtest() {
    if ! command -v speedtest &> /dev/null; then
        echo "Error: speedtest CLI not found"
        exit 1
    fi

    speedtest_output=$(speedtest --json 2>/dev/null) || {
        echo "Error: failed to run speedtest"
        exit 1
    }
}

# Parse Speedtest results
parse_speedtest_results() {
    download_speed=$(echo "$speedtest_output" | jq '.download / 1000000 | ( . * 100 + 0.5 | floor) / 100')
    upload_speed=$(echo "$speedtest_output" | jq '.upload / 1000000 | ( . * 100 + 0.5 | floor) / 100')
    ping_latency=$(echo "$speedtest_output" | jq '.ping | ( . * 1000 + 0.5 | floor) / 1000')
}

# Expose the results in Prometheus format
expose_metrics() {
    cat <<EOF
# HELP $DOWNLOAD_METRIC Download speed in Mbps
# TYPE $DOWNLOAD_METRIC gauge
$DOWNLOAD_METRIC $download_speed

# HELP $UPLOAD_METRIC Upload speed in Mbps
# TYPE $UPLOAD_METRIC gauge
$UPLOAD_METRIC $upload_speed

# HELP $PING_METRIC Ping latency in milliseconds
# TYPE $PING_METRIC gauge
$PING_METRIC $ping_latency
EOF
}

# Main script
main() {
    run_speedtest
    parse_speedtest_results
    expose_metrics
}

main
