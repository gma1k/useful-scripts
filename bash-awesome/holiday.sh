#!/bin/bash

pick_option() {
  options=(
    "Paris, France - the city of love, lights, and art. Visit the Eiffel Tower, the Louvre Museum, and the Notre Dame Cathedral."
    "Sydney, Australia - the city of sun, surf, and opera. Visit the Sydney Opera House, the Harbour Bridge, and the Bondi Beach."
    "Istanbul, Turkey - the city of history, culture, and cuisine. Visit the Hagia Sophia, the Blue Mosque, and the Grand Bazaar."
    "Queenstown, New Zealand - the city of adventure, nature, and wine. Visit the Milford Sound, the Remarkables, and the Gibbston Valley."
    "Barcelona, Spain - the city of modernism, tapas, and nightlife. Visit the Sagrada Familia, the Park Guell, and the La Rambla."
     "Rotterdam, Netherlands - the city of innovation, architecture, and art. Visit the Erasmus Bridge, the Cube Houses, and the Museum Boijmans Van Beuningen."
  )
  index=$((RANDOM % ${#options[@]}))
  echo "${options[$index]}"
}

echo "Hello, friend!"
echo "I'm feeling bored today, but I don't know where to go on holiday."
echo "Can you help me choose a destination from the menu?"
echo
echo "Here are the options:"
echo
echo "1) Paris"
echo "2) Sydney"
echo "3) Istanbul"
echo "4) Queenstown"
echo "5) Barcelona"
echo
echo "Enter your choice (1/2/3/4/5): "
read choice
set -e
trap 'echo "An error occurred!"' ERR

case $choice in
  1) echo "You chose Paris. Good choice!";;
  2) echo "You chose Sydney. Nice choice!";;
  3) echo "You chose Istanbul. Great choice!";;
  4) echo "You chose Queenstown. Awesome choice!";;
  5) echo "You chose Barcelona. Amazing choice!";;
  6) echo "You chose Rotterdam. Cool choice!";;
  *) echo "Invalid choice, but I'll pick something for you anyway."
     pick_option;;
esac

echo
echo "I hope you enjoy your trip."
echo "Bon voyage!"
