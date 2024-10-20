#!/bin/bash
set -eu

# Run Speedtest and get results in JSON format
run_speedtest() {
    echo "Running speedtest..."
    speedtest_output=$(speedtest --json)
}

# Parse Speedtest results
parse_speedtest_results() {
    echo "Parsing speedtest results..."

    # Extract speeds in Mbps
    download_speed=$(echo "$speedtest_output" | jq '.download / 1000000')
    upload_speed=$(echo "$speedtest_output" | jq '.upload / 1000000')

    # Extract ping latency
    ping_latency=$(echo "$speedtest_output" | jq '.ping')
    
    # Format speeds to two decimal places
    download_speed=$(printf "%.2f" "$download_speed")
    upload_speed=$(printf "%.2f" "$upload_speed")
}

# Expose the results in Prometheus format
expose_metrics() {
    echo "Exposing metrics..."

    cat <<EOF
# HELP speedtest_download_mbps Download speed in Mbps
# TYPE speedtest_download_mbps gauge
speedtest_download_mbps $download_speed

# HELP speedtest_upload_mbps Upload speed in Mbps
# TYPE speedtest_upload_mbps gauge
speedtest_upload_mbps $upload_speed

# HELP speedtest_ping_latency_ms Ping latency in milliseconds
# TYPE speedtest_ping_latency_ms gauge
speedtest_ping_latency_ms $ping_latency
EOF
}

# Main script
main() {
    run_speedtest
    parse_speedtest_results
    expose_metrics
}

main
