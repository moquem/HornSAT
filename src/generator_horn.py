import random
import sys
import os

MAX_VAR = 10000
MAX_CLAUSE = 500000

def sat_random_horn(n):
    model = [random.randint(0,1) for _ in range(n)]        # On génère un modèle et on va construire des clauses qui le respecte.
    hs = set()

    nb_sgl = random.randint(0,n)                           # Création des singletons : c'est ça qui impose certaines assignations.
    for _ in range(nb_sgl):
        v = random.randint(0,n-1)
        hs.add(frozenset([model[v]*(v+1)+(1-model[v])*(-(v+1))]))

    nb_clause = random.randint(1,int(MAX_CLAUSE/(MAX_VAR+1-n)))     # On rajoute des clauses avec au moins une variable qui respecte le modèle.
    for _ in range(nb_clause):
        cl = []
        v = random.randint(0,n-1)
        cl.append(model[v]*(v+1)+(1-model[v])*(-(v+1)))
        random_numbers = random.sample(range(1,n+1), random.randint(1,n))
        for i in random_numbers:
            cl.append(-(i+1))  
        hs.add(frozenset(cl))  

    return hs

def unsat_random_horn(n):  # n > 0
    nb_pos = 0
    nb_neg = 0
    pos = set()
    neg = set()
    not_assigned = set(range(1,n+1))

    hs = set()

    l_sgl = random.randint(1,n)          # On construit les singletons qui imposent des valeurs.
    for _ in range(l_sgl):
        pos_neg = random.randint(0,1)
        v = random.sample(not_assigned,1)
        not_assigned.remove(v[0])
        if pos_neg:
            pos.add(v[0])
            nb_pos += 1
        else:
            neg.add(v[0])
            v[0] = -v[0]
            nb_neg += 1
        hs.add(frozenset(v))

    nb_clause = random.randint(0,int(MAX_CLAUSE/(MAX_VAR+1-n)))
    for _ in range(nb_clause):                                        # On construit des clauses de manière à ce que toutes les variables soient déjà assignées sauf une -> impose son assignation.
        if nb_pos + nb_neg < n:
            sample_size = random.randint(0,nb_pos)
            cl = random.sample(pos,sample_size)
            for i in range(len(cl)):
                cl[i] = -cl[i]
            value = random.randint(0,min(1,nb_neg))
            if value:
                v = random.sample(neg,1)
                cl.append(v[0])
                v = random.sample(not_assigned,1)
                cl.append(-v[0])
                not_assigned.remove(v[0])
                neg.add(v[0])
                nb_neg += 1
            else:
                value = random.randint(0,1)
                v = random.sample(not_assigned,1)
                not_assigned.remove(v[0])
                if value:
                    pos.add(v[0])
                    nb_pos += 1
                    cl.append(v[0])
                else:
                    neg.add(v[0])
                    nb_neg += 1
                    cl.append(-v[0])
            hs.add(frozenset(cl))
    
    v = None                          # Ajout d'une clause unsat.
    if nb_neg == 0:
        deb = 1
                
    else:
        deb = 0
        v = random.sample(neg,1)

    sample_size = random.randint(deb,nb_pos)
    cl = random.sample(pos,sample_size)
    for i in range(len(cl)):
        cl[i] = -cl[i]
    
    if v != None:
        cl.append(v[0])

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

def unsat_format_horn(nb_var,hs_model,id):     # Permet de créer des fichiers tests.cnf
    outputFile_hs = open(os.path.join('/home/maena/Documents/Etude/ENS Paris-Saclay/M1/logia/part2/HornSAT/tests/HS/KO/test'+str(nb_var)+'_'+str(id)+'.cnf'),"w")
    outputFile_cnf = open(os.path.join('/home/maena/Documents/Etude/ENS Paris-Saclay/M1/logia/part2/HornSAT/tests/DPLL/KO/test'+str(nb_var)+'_'+str(id)+'.cnf'),"w")
   

    outputFile_hs.writelines("p hs "+str(nb_var)+" "+str(len(hs_model))+"\n")
    outputFile_cnf.writelines("p cnf "+str(nb_var)+" "+str(len(hs_model))+"\n")

    for i in hs_model:
        cl = ""
        for elt in i:
            cl += str(elt)+" "
        cl += "0"
        outputFile_hs.writelines(cl+"\n")
        outputFile_cnf.writelines(cl+"\n")

"""
for i in range(1,MAX_VAR+1):
    test_1 = random.randint(0,1)   # On ne fait pas des tests forcément pour chaque nombre de variables.
    test_2 = random.randint(0,1)
    test_3 = random.randint(0,1)
    test_4 = random.randint(0,1)
    nb_test = random.randint(0,3)       # Combien de tests on fait pour ce nombre.
    for id_test in range(test_1*test_2*test_3*test_4*nb_test):
        sat_format_horn(i,sat_random_horn(i),id_test)
"""

for i in range(1,100):
    test_1 = random.randint(0,1)   # On ne fait pas des tests forcément pour chaque nombre de variables.
    test_2 = random.randint(0,1)
    test_3 = random.randint(0,1)
    test_4 = random.randint(0,1)
    nb_test = random.randint(0,3)       # Combien de tests on fait pour ce nombre.
    for id_test in range(test_1*test_2*test_3*test_4*nb_test):
        unsat_format_horn(i,unsat_random_horn(i),id_test)