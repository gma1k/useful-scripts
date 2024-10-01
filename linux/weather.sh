#!/bin/bash
set -eu

# Get the current weather
get_current_weather() {
    local city=$1
    city="${city// /%20}"
    
    local weather=$(curl -s "http://wttr.in/${city}?format=%l|%C|%t|%f|%h|%w|%p|%P|%m|%S|%s")

    if [[ -z "$weather" || "$weather" == *"error"* ]]; then
        echo "Error: Unable to fetch weather data for '$city'."
        return 1
    fi

    IFS='|' read -r location condition temperature feelslike humidity wind precipitation pressure moonphase sunrise sunset <<< "$weather"
    
    echo -e "\nWeather Report for: $location\n"
    echo "Condition: $condition"
    echo "Temperature: $temperature"
    echo "FeelsLike: $feelslike"
    echo "Humidity: $humidity"
    echo "Wind: $wind"
    echo "Precipitation: $precipitation"
    echo "Pressure: $pressure"
    echo "MoonPhase: $moonphase"
    echo "Sunrise: ${sunrise%:*}"
    echo "Sunset: ${sunset%:*}"
}

# Main script
echo "Enter the city:"
read city

get_current_weather "$city"
