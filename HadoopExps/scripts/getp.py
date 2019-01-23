import os


p = os.environ['OAR_NODE_FILE']
f = open(p, "r")

a = f.readlines()
b = [c[:-1]+":9100" for c in a]
b = list(set(b))

f.close()


print(b)
