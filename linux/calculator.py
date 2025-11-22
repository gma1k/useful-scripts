#!/usr/bin/env python3

import tkinter as tk
import math

def update_display(button_value):
    current_value = display.get()
    if current_value == "0":
        display.delete(0, tk.END)
        display.insert(0, button_value)
    else:
        display.insert(tk.END, button_value)

def clear_display():
    display.delete(0, tk.END)
    display.insert(0, "0")

def evaluate_display():
    expression = display.get()
    try:
        result = eval(expression)
        clear_display()
        display.insert(0, result)
    except:
        clear_display()
        display.insert(0, "Invalid input")

root = tk.Tk()
root.title("Calculator")
root.geometry("375x500")

display = tk.Entry(root, font=("Arial", 20), justify="right")
display.place(x=0, y=0, width=375, height=50) # Changed this line
display.insert(0, "0")

buttons = ["7", "8", "9", "+",
           "4", "5", "6", "-",
           "1", "2", "3", "*",
           "0", ".", "=", "/",
           "C", "sqrt", "**", "sin",
           "cos", "tan"]

colors = ["lightgray", "lightgray", "lightgray", "orange",
          "lightgray", "lightgray", "lightgray", "orange",
          "lightgray", "lightgray", "lightgray", "orange",
          "lightgray", "lightgray", "orange", "orange",
          "red", "orange", "orange", "orange",
          "orange", "orange"]

for i in range(len(buttons)):
    button = tk.Button(root, text=buttons[i], font=("Arial", 20), bg=colors[i])
    button.place(x=(i%5)*75, y=(i//5)*75+50, width=75, height=75) # Changed this line
    if buttons[i] == "=":
        button.configure(command=evaluate_display)
    elif buttons[i] == "C":
        button.configure(command=clear_display)
    elif buttons[i] == "**": 
        button.configure(command=lambda value="**": update_display(value))
    elif buttons[i] == "sqrt": 
        button.configure(command=lambda value="math.sqrt(": update_display(value))
    elif buttons[i] == "sin": 
        button.configure(command=lambda value="math.sin(": update_display(value))
    elif buttons[i] == "cos": 
        button.configure(command=lambda value="math.cos(": update_display(value))
    elif buttons[i] == "tan": 
        button.configure(command=lambda value="math.tan(": update_display(value))
    else:
        button.configure(command=lambda value=buttons[i]: update_display(value))

root.mainloop()
