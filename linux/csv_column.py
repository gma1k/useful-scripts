import csv
import sys


if __name__ == "__main__":
    csvfile = csv.reader(sys.stdin)

    column_number = 0
    if len(sys.argv) > 1:
            column_number = int(sys.argv[1])

    for row in csvfile:
            print row[column_number]
