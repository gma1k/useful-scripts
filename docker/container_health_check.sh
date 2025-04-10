#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

print_header() {
    echo -e "${CYAN}Checking Docker container health status...${RESET}\n"
}

get_running_containers() {
    docker ps --format "{{.Names}}"
}

get_health_status() {
    local container="$1"
    docker inspect --format '{{.State.Health.Status}}' "$container" 2>/dev/null
}

print_status() {
    local container="$1"
    local status="$2"
    local color="$3"
    echo -e "Container: ${container} - Status: ${color}${status}${RESET}"
}

check_containers() {
    local containers
    containers=$(get_running_containers)

    if [[ -z "$containers" ]]; then
        echo -e "${YELLOW}No running containers found.${RESET}"
        return
    fi

    for container in $containers; do
        local status
        status=$(get_health_status "$container")

        if [[ -z "$status" ]]; then
            print_status "$container" "no health check" "$YELLOW"
        elif [[ "$status" == "healthy" ]]; then
            print_status "$container" "$status" "$GREEN"
        elif [[ "$status" == "unhealthy" ]]; then
            print_status "$container" "$status" "$RED"
        else
            print_status "$container" "$status" "$YELLOW"
        fi
    done
}

main() {
    print_header
    check_containers
}

main
