#!/usr/bin/env python

import sys

if __name__ == "__main__":
    names = {}
    for name in sys.stdin.readlines():
           
            name = name.strip()
            if name in names:
                    names[name] += 1
            else:
                    names[name] = 1

    for name, count in names.iteritems():
            sys.stdout.write("%d\t%s\n" % (count, name))
