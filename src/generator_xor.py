import random
import sys
import os

MAX_VAR = 10000
MAX_CLAUSE = 500000

def sat_random_xor(n):
    model = [random.randint(0,1) for _ in range(n)]        # On génère un modèle et on va construire des clauses qui le respecte.
    hs = set()

    nb_clause = random.randint(1,int(MAX_CLAUSE/(MAX_VAR+1-n)))     # On rajoute des clauses avec un nombre impair de 1.
    for _ in range(nb_clause):
        cl = []
        un = 0
        random_numbers = random.sample(range(0,n), random.randint(1,n))
        for i in range (len(random_numbers)-1):
            v = random_numbers[i]
            value = random.randint(0,1)
            cl.append(-(v+1)*(1-value) + (v+1)*value)
            if (not(model[v]) and not(value)) or (model[v] and value):
                un += 1
        last_v = random_numbers[-1]   # Il faut ajouter la dernière variable de manière à être sûr d'avoir un nombre impair de 1.
        value = model[last_v]
        if (value and not(un%2)) or (not(value) and un%2):
            cl.append(last_v+1)
        else:
            cl.append(-(last_v+1))

            
        hs.add(frozenset(cl))  

    return hs


def sat_format_xor(nb_var,hs_model,id):     # Permet de créer des fichiers tests.cnf
    outputFile = open(os.path.join('/home/maena/Documents/Etude/ENS Paris-Saclay/M1/logia/part2/HornSAT/tests/XNF/OK/test'+str(nb_var)+'_'+str(id)+'.cnf'),"w")   

    outputFile.writelines("p xnf "+str(nb_var)+" "+str(len(hs_model))+"\n")

    for i in hs_model:
        cl = ""
        for elt in i:
            cl += str(elt)+" "
        cl += "0"
        outputFile.writelines(cl+"\n")


for i in range(1,500):
    test_1 = random.randint(0,1)   # On ne fait pas des tests forcément pour chaque nombre de variables.
    test_2 = random.randint(0,1)
    test_3 = random.randint(0,1)
    test_4 = random.randint(0,1)
    nb_test = random.randint(0,3)       # Combien de tests on fait pour ce nombre.
    for id_test in range(test_1*test_2*test_3*test_4*nb_test):
        sat_format_xor(i,sat_random_xor(i),id_test)