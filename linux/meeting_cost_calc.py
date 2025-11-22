#!/usr/bin/env python3

import colorama
from colorama import Fore, Style
import csv
import argparse
from prettytable import PrettyTable

class Meeting:
  def __init__(self, people, rates, duration):
    self.people = people
    self.rates = rates
    self.duration = duration

  def cost(self):
    total_cost = 0.0
    for rate in self.rates.values():
      total_cost += rate * self.duration
    return total_cost

  def print_details(self):
    table = PrettyTable()
    table.field_names = ['Name', 'Hourly Rate', 'Cost']
    table.align['Name'] = 'l'
    table.align['Hourly Rate'] = 'r'
    table.align['Cost'] = 'r'
    for name, rate in self.rates.items():
      table.add_row([name, f"${'%.2f' % rate}", f"${'%.2f' % (rate * self.duration)}"])
    table.add_row(['Total', '', f"${'%.2f' % self.cost()}"])
    print(Fore.BLUE + "The details of the meeting are:")
    print(Fore.GREEN + str(table))
    print(Style.RESET_ALL)

  def save_to_file(self, filename):
    with open(filename, "a") as file:
      writer = csv.writer(file)
      writer.writerow(["Date", "Time", "People", "Duration"])
      writer.writerow([datetime.date.today(), datetime.datetime.now().strftime("%H:%M:%S"), self.people, self.duration])
      writer.writerow(["Name", "Hourly Rate", "Cost"])
      for name, rate in self.rates.items():
        writer.writerow([name, rate, rate * self.duration])
      writer.writerow(["Total", "", self.cost()])
      writer.writerow([])
    print(Fore.BLUE + f"The details of the meeting have been saved to {filename}.")
    print(Style.RESET_ALL)

  @classmethod
  def get_input(cls, options):
    while True:
      try:
        people = int(input("How many people are in the meeting? "))
        if people > 0:
          break
        else:
          raise ValueError
      except ValueError:
        print("Please enter a positive integer.")
        
    rates = {}

    for i in range(people):
      while True:
        try:
          name = input(f"What is the name of person {i+1}? ")
          if name.isalpha():
            break
          else:
            raise ValueError
        except ValueError:
          print("Please enter a valid name.")
          
      while True:
        try:
          rate = float(input(f"What is the hourly rate of {name}? "))
          if rate > 0.0:
            break
          else:
            raise ValueError
        except ValueError:
          print("Please enter a positive number.")

      rates[name] = rate

    while True:
      try:
        duration = float(input("How long is the meeting in hours? "))
        if duration > 0.0:
          break
        else:
          raise ValueError
      except ValueError:
        print("Please enter a positive number.")

    while True:
      try:
        edit = input("Do you want to edit or delete any input? (y/n) ").lower()
        if edit in ['y', 'n']:
          break
        else:
          raise ValueError
      except ValueError:
        print("Please enter y or n.")
        
    while edit == 'y':
      while True:
        try:
          choice = input("What do you want to do? (edit/delete/done) ").lower()
          if choice in ['edit', 'delete', 'done']:
            break
          else:
            raise ValueError
        except ValueError:
          print("Please enter a valid option.")
          
      if choice == 'edit':
        cls.edit_input(rates)
      elif choice == 'delete':
        cls.delete_input(rates)
      elif choice == 'done':
        break

    people = len(rates)

    if options.round:
      for name, rate in rates.items():
        rates[name] = round(rate)

    return cls(people, rates, duration)

  @classmethod
  def edit_input(cls, rates):
    while True:
      try:
        name = input("Who do you want to edit? ")
        if name in rates.keys():
          break
        else:
          raise ValueError
      except ValueError:
        print("Please enter a valid name.")

    while True:
      try:
        rate = float(input(f"What is the new hourly rate of {name}? "))
        if rate > 0.0:
          break
        else:
          raise ValueError
      except ValueError:
        print("Please enter a positive number.")

    rates[name] = rate

    print(Fore.BLUE + f"{name}'s hourly rate has been updated to ${'%.2f' % rate}.")
    print(Style.RESET_ALL)

  @classmethod
  def delete_input(cls, rates):
    while True:
      try:
        name = input("Who do you want to delete? ")
        if name in rates.keys():
          break
        else:
          raise ValueError
      except ValueError:
        print("Please enter a valid name.")
        
    del rates[name]

    print(Fore.BLUE + f"{name} has been deleted from the meeting.")
    print(Style.RESET_ALL)
    
options = {}
arg_parser = argparse.ArgumentParser(description="A python script that calculates the total cost of a meeting based on the number of people and their hourly rates")
arg_parser.add_argument("-r", "--round", action="store_true", help="round the cost to an integer value")
arg_parser.add_argument("-s", "--save", metavar="FILENAME", type=str, help="save the output to a file")
options = vars(arg_parser.parse_args())
meeting = Meeting.get_input(options)
meeting.print_details()

if options["save"]:
  meeting.save_to_file(options["save"])
