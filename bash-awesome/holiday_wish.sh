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
echo "Are you feeling bored today? Do you want to go on holiday?"
echo
echo "What kind of holiday do you wish for?"
echo
echo "1) A romantic holiday"
echo "2) A sunny holiday"
echo "3) A cultural holiday"
echo "4) An adventurous holiday"
echo "5) A fun holiday"
echo "6) A creative holiday"
echo
echo "Enter your choice (1/2/3/4/5/6): "
read choice
set -e
trap 'echo "An error occurred!"' ERR
case $choice in
  1) echo "You wish for a romantic holiday. How about Paris?";;
  2) echo "You wish for a sunny holiday. How about Sydney?";;
  3) echo "You wish for a cultural holiday. How about Istanbul?";;
  4) echo "You wish for an adventurous holiday. How about Queenstown?";;
  5) echo "You wish for a fun holiday. How about Barcelona?";;
  6) echo "You wish for a innovative & creative holiday. How about Rotterdam?";;
  *) echo "Invalid choice, but I'll pick something for you anyway."
     pick_option;;
esac

echo
echo "I hope you enjoy your trip."
echo "Bon voyage!"
