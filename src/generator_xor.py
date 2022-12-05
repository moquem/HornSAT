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

def unsat_random_xor(n):  # n > 0
    pos = set()
    neg = set()
    not_assigned = set(range(1,n+1))

    hs = set()

    nb_clause = random.randint(1,int(MAX_CLAUSE/(MAX_VAR+1-n)))
    for _ in range(nb_clause):                                        # On construit des clauses de manière à ce que toutes les variables soient déjà assignées sauf une -> impose son assignation.
        if len(not_assigned) > 0:
            taille_pos = 0

            sample_size = random.randint(0,len(pos))
            cl1 = random.sample(pos,sample_size)
            for i in range(len(cl1)):
                pos_neg = random.randint(0,1)
                cl1[i] = -cl1[i]*(1-pos_neg) + cl1[i]*pos_neg
                taille_pos += pos_neg

            sample_size = random.randint(0,len(neg))
            cl2 = random.sample(neg,sample_size)
            for i in range(len(cl2)):
                pos_neg = random.randint(0,1)
                cl2[i] = -cl2[i]*pos_neg + cl2[i]*(1-pos_neg)
                taille_pos += pos_neg
            
            cl1.extend(cl2)
            v = random.sample(not_assigned,1)
            v = v[0]
            not_assigned.remove(v)
            value = random.randint(0,1)
            if taille_pos % 2 == 0:
                if value:
                    cl1.append(v)
                    pos.add(v)
                else:
                    cl1.append(-v)
                    neg.add(v)
            else:
                if value:
                    cl1.append(-v)
                    pos.add(v)
                else:
                    cl1.append(v)
                    neg.add(v)

            hs.add(frozenset(cl1))
        
        else:
            break

        
    sample_size_neg = random.randint(min(1,len(neg)),len(neg))
    sample_size_pos = random.randint(min(1,len(pos)-1),max(0,len(pos)-1))

    if sample_size_pos%2==1:
        sample_size_pos += 1

    if sample_size_pos == 0 and sample_size_neg == 0:
        v = random.sample(pos,1)
        v[0] = -v[0]

        hs.add(frozenset(v))
    
    else:
        cl1 = random.sample(neg,sample_size_neg)
        cl2= random.sample(pos,sample_size_pos)

        cl1.extend(cl2)
        hs.add(frozenset(cl1))

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


def unsat_format_xor(nb_var,hs_model,id):     # Permet de créer des fichiers tests.cnf
    outputFile = open(os.path.join('/home/maena/Documents/Etude/ENS Paris-Saclay/M1/logia/part2/HornSAT/tests/XNF/KO/test'+str(nb_var)+'_'+str(id)+'.cnf'),"w")   

    outputFile.writelines("p xnf "+str(nb_var)+" "+str(len(hs_model))+"\n")

    for i in hs_model:
        cl = ""
        for elt in i:
            cl += str(elt)+" "
        cl += "0"
        outputFile.writelines(cl+"\n")


for i in range(1,1000):
    test_1 = random.randint(0,1)   # On ne fait pas des tests forcément pour chaque nombre de variables.
    test_2 = random.randint(0,1)
    test_3 = random.randint(0,1)
    test_4 = random.randint(0,1)
    nb_test = random.randint(0,3)       # Combien de tests on fait pour ce nombre. 
    for id_test in range(test_1*test_2*test_3*test_4*nb_test):
        unsat_format_xor(i,unsat_random_xor(i),id_test)