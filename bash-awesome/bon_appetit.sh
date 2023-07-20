#!/bin/bash

pick_option() {
  options=(
    "Pizza with extra cheese and pepperoni"
    "Sushi with salmon and avocado"
    "Burger with bacon and cheese"
    "Salad with chicken and dressing"
    "Pasta with tomato sauce and meatballs"
  )
  index=$((RANDOM % ${#options[@]}))
  echo "${options[$index]}"
}

echo "Hello, friend!"
echo "I'm feeling hungry today, but I don't know what to eat."
echo "Can you help me choose something from the menu?"
echo
echo "Here are the options:"
echo
echo "1) Pizza"
echo "2) Sushi"
echo "3) Burger"
echo "4) Salad"
echo "5) Pasta"
echo
echo "Enter your choice (1/2/3/4/5): "
read choice
set -e
trap 'echo "An error occurred!"' ERR

case $choice in
  1) echo "You chose pizza. Good choice!";;
  2) echo "You chose sushi. Nice choice!";;
  3) echo "You chose burger. Great choice!";;
  4) echo "You chose salad. Healthy choice!";;
  5) echo "You chose pasta. Delicious choice!";;
  *) echo "Invalid choice, but I'll pick something for you anyway."
     pick_option;;
esac

echo
echo "I hope you enjoy your meal."
echo "Bon appetit!"
