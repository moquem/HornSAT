import random
import sys
import os

MAX_VAR = 300
MAX_CLAUSE = 50000

def sat_random_horn(n):
    model = [random.randint(0,1) for _ in range(n)]        # On génère un modèle et on va construire des clauses qui le respecte.
    hs = set()

    nb_sgl = random.randint(0,n)                           # Création des singletons : c'est ça qui impose certaines assignations.
    for _ in range(nb_sgl):
        v = random.randint(0,n-1)
        hs.add(frozenset([model[v]*(v+1)+(1-model[v])*(-(v+1))]))

    nb_clause = random.randint(0,int(MAX_CLAUSE/(MAX_VAR+1-n)))     # On rajoute des clauses avec au moins une variable qui respecte le modèle.
    for _ in range(nb_clause):
        cl = []
        v = random.randint(0,n-1)
        cl.append(model[v]*(v+1)+(1-model[v])*(-(v+1)))
        random_numbers = random.sample(range(1,n+1), random.randint(1,n))
        for i in random_numbers:
            cl.append(-(i+1))  
        hs.add(frozenset(cl))  

    return hs

def sat_format_horn(nb_var,hs_model,id):     # Permet de créer des fichiers tests.cnf
    outputFile_hs = open(os.path.join('/home/maena/Documents/Etude/ENS Paris-Saclay/M1/logia/part2/HornSAT/tests/HS/OK/test'+str(nb_var)+'_'+str(id)+'.cnf'),"w")
    outputFile_cnf = open(os.path.join('/home/maena/Documents/Etude/ENS Paris-Saclay/M1/logia/part2/HornSAT/tests/DPLL/OK/test'+str(nb_var)+'_'+str(id)+'.cnf'),"w")
   

    outputFile_hs.writelines("p hs "+str(nb_var)+" "+str(len(hs_model))+"\n")
    outputFile_cnf.writelines("p cnf "+str(nb_var)+" "+str(len(hs_model))+"\n")

    for i in hs_model:
        cl = ""
        for elt in i:
            cl += str(elt)+" "
        cl += "0"
        outputFile_hs.writelines(cl+"\n")
        outputFile_cnf.writelines(cl+"\n")


for i in range(1,MAX_VAR+1):
    test_1 = random.randint(0,1)   # On ne fait pas des tests forcément pour chaque nombre de variables.
    test_2 = random.randint(0,1)
    nb_test = random.randint(1,3)       # Combien de tests on fait pour ce nombre.
    for id_test in range(test_1*test_2*nb_test):
        sat_format_horn(i,sat_random_horn(i),id_test)