import math
x = 4
n = 3

power = x ** n
print("%d to the power %d is %d" % (x, n, power))

power = pow(x, n)
print("%d to the power %d is %d" % (x, n, power))

power = math.pow(2, 6.5)
print("%d to the power %d is %5.2f" % (x, n, power))
