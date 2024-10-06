#!/usr/bin/python3

import requests
from datetime import datetime

# Define a Slack webhook URL
SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Tree pruning periods
PRUNING_TIMES = {
    "Grape Tree (Winter)": (11, 12),   # November - December
    "Fig Tree": (12, 2),   # December - February
    "Kiwi Tree": (12, 1),     # December - January
    "Olive Tree": (3, 4),     # March - April
    "Roses": (3, 4),          # March - April
    "Grape Tree (Summer)": (5, 6),    # May - June
}

# Send a notification to Slack
def send_slack_notification(message):
    payload = {
        "text": message
    }
    response = requests.post(SLACK_WEBHOOK_URL, json=payload)
    if response.status_code != 200:
        raise Exception(f"Request to Slack returned an error {response.status_code}, the response is: {response.text}")

# Get the current month
current_month = datetime.now().month

# Check for trees and plants that need pruning
def check_pruning_times():
    plants_to_prune = []
    for plant, (start_month, end_month) in PRUNING_TIMES.items():
        if start_month <= current_month <= end_month:
            plants_to_prune.append(plant)

    if plants_to_prune:
        message = f"The following plants should be pruned this month:\n" + "\n".join(plants_to_prune)
    else:
        message = "No plants need pruning this month."

    send_slack_notification(message)

if __name__ == "__main__":
    check_pruning_times()
