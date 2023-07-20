#!/bin/bash

say_something() {
  sentences=(
    "Bash is so awesome, it can loop over anything, even your mom."
    "Bash is so awesome, it can make functions out of thin air, just like magic."
    "Bash is so awesome, it can do anything you want, as long as you ask nicely."
    "Bash is so awesome, it can make you laugh, cry, or scream, depending on your mood."
    "Bash is so awesome, it can run on any platform, even on a toaster."
  )
  index=$((RANDOM % ${#sentences[@]}))
  echo "${sentences[$index]}"
}

for name in "$@"; do
  echo "Hey, $name!"
  echo "Do you want to hear something cool? (y/n)"
  read answer
  if [ "$answer" == "y" ]; then
    say_something
  elif [ "$answer" == "n" ]; then
    echo "Too bad, I'll tell you something anyway."
    say_something
  else
    echo "Invalid answer, but I'll tell you something anyway."
    say_something
  fi
  echo
done

echo "That's all folks!"
