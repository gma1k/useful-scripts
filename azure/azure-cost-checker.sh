#!/bin/bash

ask_subscription() {
    read -rp "Enter your Azure Subscription ID: " SUBSCRIPTION_ID
}

total_cost() {
    echo "Fetching total cost for subscription $SUBSCRIPTION_ID ..."
    az consumption usage list --subscription "$SUBSCRIPTION_ID" --query '[].cost' --output tsv | awk '{s+=$1} END {print "Total cost: $" s}'
}

cost_by_location() {
    echo "Fetching cost breakdown by location for subscription $SUBSCRIPTION_ID ..."
    az consumption usage list --subscription "$SUBSCRIPTION_ID" \
        --query '[].{Location: location, Cost: cost}' --output json | jq -r '.[] | "\(.Location) \(.Cost)"' | \
        awk '{cost[$1]+=$2} END {for (loc in cost) printf "%s: $%.2f\n", loc, cost[loc]}'
}

show_menu() {
    echo "========================="
    echo " Azure Cost Usage Menu"
    echo "========================="
    echo "1. Get total cost for a subscription"
    echo "2. Get cost by location"
    echo "3. Exit"
}

main() {
    ask_subscription
    show_menu
    read -rp "Choose an option [1-3]: " choice

    case $choice in
        1)
            total_cost
            ;;
        2)
            cost_by_location
            ;;
        3)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
}

main
