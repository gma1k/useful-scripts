#!/bin/bash

tell_joke() {
  jokes=(
    "How do you make a tissue dance? You put a little boogie in it."
    "What do you call a fish wearing a bowtie? Sofishticated."
    "What do you call a dog that can tell time? A watch dog."
    "What do you get when you cross a snowman and a vampire? Frostbite."
    "Why did the chicken go to the seance? To get to the other side."
  )
  index=$((RANDOM % ${#jokes[@]}))
  echo "${jokes[$index]}"
}

for name in "$@"; do
  echo "Hello, $name!"
  echo "Do you want to hear a joke? (y/n)"
  read answer
  if [ "$answer" == "y" ]; then
    tell_joke
  elif [ "$answer" == "n" ]; then
    echo "Too bad, here's one anyway."
    tell_joke
  else
    echo "Invalid answer, but I'll tell you a joke anyway."
    tell_joke
  fi
  echo
done

echo "That's all folks!"
