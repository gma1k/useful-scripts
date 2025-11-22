#!/bin/bash

# Change the keyboard layout
function prank1() {
    current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')
    possible_layouts=(dvorak colemak neo fr ru)
    random_layout=${possible_layouts[$RANDOM % ${#possible_layouts[@]}]}
    setxkbmap $random_layout
    echo "Prank 1: Keyboard layout changed from $current_layout to $random_layout. Good luck typing!"
}

# Replace the sound effects with funny or annoying ones
function prank2() {
    current_theme=$(gsettings get org.gnome.desktop.sound theme-name)
    possible_themes=(freedesktop yaru ubuntu gnome)
    random_theme=${possible_themes[$RANDOM % ${#possible_themes[@]}]}
    gsettings set org.gnome.desktop.sound theme-name $random_theme
    echo "Prank 2: Sound theme changed from $current_theme to $random_theme. Enjoy the new sounds!"
}

# Make the terminal say rude things to the user
function prank3() {
    possible_messages=("Happy to see you so bad xD" "Go away!" "You smell bad xD" "Loser xD")
    random_message=${possible_messages[$RANDOM % ${#possible_messages[@]}]}
    echo "echo \"$random_message\"" >> ~/.bashrc
    echo "Prank 3: Terminal will say \"$random_message\" every time you open it. How rude!"
}

# Make the mouse pointer disappear or move randomly
function prank4() {
    random_number=$((1 + $RANDOM % 2))
    if [ $random_number -eq 1 ]; then
        unclutter -idle 0 -root &
        echo "Prank 4: Mouse pointer disappeared. Where did it go?"
    else
        while true; do
            xte "mousemove $((1 + $RANDOM % 1920)) $((1 + $RANDOM % 1080))" "usleep 100000"
        done &
        echo "Prank 4: Mouse pointer moving randomly. What is it doing?"
    fi
}

# Make the screen go blank or inverted
function prank5() {
    random_number=$((1 + $RANDOM % 2))
    if [ $random_number -eq 1 ]; then
        xset dpms force off &
        echo "Prank 5: Screen went blank. Is it broken?"
    else
        xrandr --output $(xrandr | grep " connected" | cut -f1 -d" ") --rotate inverted &
        echo "Prank 5: Screen inverted. Is it upside down?"
    fi
}

echo "Welcome to the prank script. Please choose a prank from the following options:"
echo "1) Change keyboard layout"
echo "2) Replace sound effects"
echo "3) Make terminal say rude things"
echo "4) Make mouse pointer disappear or move randomly"
echo "5) Make screen go blank or inverted"
echo "6) Exit"

read -p "Enter your choice (1-6): " choice

case $choice in
    1) prank1 ;;
    2) prank2 ;;
    3) prank3 ;;
    4) prank4 ;;
    5) prank5 ;;
    6) exit 0 ;;
    *) echo "Invalid choice. Please try again." ;;
esac
