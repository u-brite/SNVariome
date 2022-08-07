#!/usr/bin/python

protein = open('Proteins.csv').read().splitlines()
pair = open('Human_Interactome.csv').read().splitlines()

out = []
#for i in protein:
for j in pair:
    j = j.strip()
    a,b = j.split(',')
    if a in protein or b in protein and j not in out:out.append(j)

out = list(set(out))
fh = open('Proteins_Human_Interactome.csv','w')
for i in out:print(i, file=fh)
for i in out:print(i)
print(len(out))

#and: exclusive pairs
#or: all possible pairs
