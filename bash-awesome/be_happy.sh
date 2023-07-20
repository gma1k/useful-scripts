#!/bin/bash

say_compliment() {
  compliments=(
    "You are awesome, and you know it."
    "You are smart, and you show it."
    "You are beautiful, and you glow it."
    "You are strong, and you grow it."
    "You are kind, and you sow it."
  )
  index=$((RANDOM % ${#compliments[@]}))
  echo "${compliments[$index]}"
}

say_joke() {
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

say_quote() {
  quotes=(
    "Don't cry because it's over, smile because it happened. - Dr. Seuss"
    "Be the change that you wish to see in the world. - Mahatma Gandhi"
    "The only thing we have to fear is fear itself. - Franklin D. Roosevelt"
    "The journey of a thousand miles begins with a single step. - Lao Tzu"
    "The most important thing is to enjoy your life - to be happy - it's all that matters. - Audrey Hepburn"
  )
  index=$((RANDOM % ${#quotes[@]}))
  echo "${quotes[$index]}"
}

say_tip() {
  tips=(
    "Take a deep breath and relax your shoulders."
    "Drink some water and stay hydrated."
    "Listen to some music and dance like no one's watching."
    "Write down three things you are grateful for today."
    "Call or text someone you love and tell them how much they mean to you."
  )
  index=$((RANDOM % ${#tips[@]}))
  echo "${tips[$index]}"
}

echo "Hello, friend!"
echo "I'm sorry to hear that you had a bad day."
echo "But don't worry, I'm here to help you feel better."
echo
echo "What would you like me to do for you?"
echo
echo "1) Say something nice about you"
echo "2) Tell you a funny joke"
echo "3) Share with you an inspiring quote"
echo "4) Give you some helpful tips"
echo
echo "Enter your choice (1/2/3/4): "
read choice
set -e
trap 'echo "An error occurred!"' ERR

case $choice in
  1) say_compliment;;
  2) say_joke;;
  3) say_quote;;
  4) say_tip;;
  *) echo "Invalid choice, but I'll do something anyway."
     say_compliment;;
esac
echo
echo "I hope this made you smile and feel better."
echo "Remember, you are not alone, and you can always count on me."
echo "Have a wonderful day!"
