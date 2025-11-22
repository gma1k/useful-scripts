#!/usr/bin/env python3

import requests
import json
import datetime
import matplotlib.pyplot as plt

countries = ["Netherlands", "Belgium", "Germany"]
cities = {"Netherlands": ["Amsterdam", "Rotterdam", "Utrecht"],
          "Belgium": ["Brussels", "Antwerp", "Ghent"],
          "Germany": ["Berlin", "Munich", "Cologne"]}

api_key = "YOUR_API_KEY"
base_url = "http://api.openweathermap.org/data/2.5/"

weather_data = []

user_input = input("Do you want to see the weather for all countries or select some? (all/select): ")

if user_input == "all":
    for country in countries:
        for city in cities[country]:
            full_url = base_url + "weather?q=" + city + "&appid=" + api_key + "&units=metric&lang=en"
            response = requests.get(full_url).json()
            city_name = response["name"]
            temperature = response["main"]["temp"]
            humidity = response["main"]["humidity"]
            wind_speed = response["wind"]["speed"]
            weather_description = response["weather"][0]["description"]
            weather_data.append({"country": country,
                             "city": city_name,
                             "temperature": temperature,
                             "humidity": humidity,
                             "wind_speed": wind_speed,
                             "weather_description": weather_description})
            
            full_url = base_url + "forecast?q=" + city + "&appid=" + api_key + "&units=metric&lang=en"
            response = requests.get(full_url).json()
            temperature_forecast = response["list"][5]["main"]["temp"]
            humidity_forecast = response["list"][5]["main"]["humidity"]
            wind_speed_forecast = response["list"][5]["wind"]["speed"]
            weather_description_forecast = response["list"][5]["weather"][0]["description"]
            weather_data.append({"country": country,
                             "city": city_name,
                             "temperature_forecast": temperature_forecast,
                             "humidity_forecast": humidity_forecast,
                             "wind_speed_forecast": wind_speed_forecast,
                             "weather_description_forecast": weather_description_forecast})

elif user_input == "select":
    user_input = input(f"Which countries do you want to see? Choose from {countries} and separate by commas: ")
    selected_countries = [country.strip() for country in user_input.split(",")]
    for country in selected_countries:
        if country in countries:
            for city in cities[country]:
                full_url = base_url + "weather?q=" + city + "&appid=" + api_key + "&units=metric&lang=en"
                response = requests.get(full_url).json()
                city_name = response["name"]
                temperature = response["main"]["temp"]
                humidity = response["main"]["humidity"]
                wind_speed = response["wind"]["speed"]
                weather_description = response["weather"][0]["description"]
                weather_data.append({"country": country,
                                 "city": city_name,
                                 "temperature": temperature,
                                 "humidity": humidity,
                                 "wind_speed": wind_speed,
                                 "weather_description": weather_description})
                
                full_url = base_url + "forecast?q=" + city + "&appid=" + api_key + "&units=metric&lang=en"
                response = requests.get(full_url).json()
                temperature_forecast = response["list"][5]["main"]["temp"]
                humidity_forecast = response["list"][5]["main"]["humidity"]
                wind_speed_forecast = response["list"][5]["wind"]["speed"]
                weather_description_forecast = response["list"][5]["weather"][0]["description"]
                weather_data.append({"country": country,
                                 "city": city_name,
                                 "temperature_forecast": temperature_forecast,
                                 "humidity_forecast": humidity_forecast,
                                 "wind_speed_forecast": wind_speed_forecast,
                                 "weather_description_forecast": weather_description_forecast})
        else:
            print(f"{country} is not a valid country. Please choose from {countries}.")

for item in weather_data:
    if "temperature" in item:
        print(f"The weather in {item['city']}, {item['country']} is now: {item['temperature']}°C, {item['humidity']}% humidity, {item['wind_speed']} m/s wind and {item['weather_description']}.")
    elif "temperature_forecast" in item:
        print(f"The forecast for tomorrow in {item['city']}, {item['country']} is: {item['temperature_forecast']}°C, {item['humidity_forecast']}% humidity, {item['wind_speed_forecast']} m/s wind and {item['weather_description_forecast']}.")

city_names = []
current_temperatures = []
forecasted_temperatures = []

for item in weather_data:
    if "temperature" in item:
        city_names.append(item["city"])
        current_temperatures.append(item["temperature"])
    elif "temperature_forecast" in item:
        forecasted_temperatures.append(item["temperature_forecast"])

fig, ax = plt.subplots()
ax.set_title("Temperature changes for different cities")
ax.set_xlabel("City")
ax.set_ylabel("Temperature (°C)")
ax.bar(city_names, current_temperatures, color="blue", label="Current")
ax.bar(city_names, forecasted_temperatures, color="red", label="Forecast", alpha=0.5)
ax.legend()
plt.show()
plt.savefig('plot.png')
