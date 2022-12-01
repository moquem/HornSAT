#!/bin/bash

pass_dpll=0
pass_hs=0
pass_xnf=0

wrong_dpll=0
wrong_hs=0
wrong_xnf=0

timeout_dpll=0
timeout_hs=0
timeout_xnf=0

fail_dpll=0
fail_hs=0
fail_xnf=0

OKDPLLFILES=$(find ./tests/DPLL/OK -name "*.cnf") 
KODPLLFILES=$(find ./tests/DPLL/KO -name "*.cnf")
OKHSFILES=$(find ./tests/HS/OK -name "*.cnf")
KOHSFILES=$(find ./tests/HS/KO -name "*.cnf")
OKXNFFILES=$(find ./tests/XNF/OK -name "*.cnf")
KOXNFFILES=$(find ./tests/XNF/KO -name "*.cnf")

# ?
echo "find ./tests/KO -path '$KODIR/*.cnf'"

TOTALOKDPLL=$(wc -w <<< "$OKDPLLFILES")
TOTALKODPLL=$(wc -w <<< "$KODPLLFILES")
TOTALOKHS=$(wc -w <<< "$OKHSFILES")
TOTALKOHS=$(wc -w <<< "$KOHSFILES")
TOTALOKXNF=$(wc -w <<< "$OKXNFFILES")
TOTALKOXNF=$(wc -w <<< "$KOXNFFILES")

TOTALDPLL=$((TOTALOKDPLL+TOTALKODPLL))
TOTALHS=$((TOTALOKHS+TOTALKOHS  ))
TOTALXNF=$((TOTALOKXNF+TOTALKOXNF ))

# TOTAL=$((TOTALDPLL+TOTALHS+TOTALXNF))
TIMEOUT=30
CMD="timeout $TIMEOUT ./dpll"


### DPLL 

echo " "
echo "------------------------"
echo "  DPLL - $TOTALDPLL TESTS"
echo "------------------------"
echo "  Running $TOTALOKDPLL satisfiable tests with TIMEOUT=$TIMEOUT"
echo "------------------------"

for i in $OKDPLLFILES ; do
    echo -n "$i... " ;
    ret=$($CMD $i);
    if [ $? -eq 124 ];
    then
	timeout_dpll=$((timeout_dpll+1));
	echo -e "\033[0;33mTIMEOUT\033[0m";
    else
	if echo $ret | grep "true" > /dev/null;
	then
	    pass_dpll=$((pass_dpll+1));
	    echo -e "\033[0;32mSUCCESS\033[0m"
	elif echo $ret | grep "false" > /dev/null;
	then
	    wrong_dpll=$((wrong_dpll+1));
	    echo -e "\033[0;31mWRONG\033[0m";
	else
	    fail_dpll=$((fail_dpll+1));
	    echo -e "\033[0;36mFAIL\033[0m";
	fi;
    fi;
done;

echo ""
echo "------------------------"
echo "  Running $TOTALKODPLL unsatisfiable tests with TIMEOUT=$TIMEOUT"
echo "------------------------"

for i in $KODPLLFILES ; do
    echo -n "$i... " ;
    ret=$($CMD $i);
    if [ $? -eq 124 ];
    then
	timeout_dpll=$((timeout_dpll+1));
	echo -e "\033[0;33mTIMEOUT\033[0m";
    else
	if echo $ret | grep "true" > /dev/null;
	then
	    wrong_dpll=$((wrong_dpll+1));
	    echo -e "\033[0;31mWRONG\033[0m";
	elif echo $ret | grep "false" > /dev/null;
	then
	    pass_dpll=$((pass_dpll+1));
	    echo -e "\033[0;32mSUCCESS\033[0m"
	else
	    fail_dpll=$((fail_dpll+1));
	    echo -e "\033[0;36mFAIL\033[0m";
	fi;
    fi;
done;

echo "------------------------"
echo -e "\033[0;31mWrong  : $wrong_dpll / $TOTALDPLL\033[0m"
echo -e "\033[0;32mPass   : $pass_dpll / $TOTALDPLL\033[0m"
echo -e "\033[0;33mTimeout: $timeout_dpll / $TOTALDPLL\033[0m"
echo -e "\033[0;36mFail   : $fail_dpll / $TOTALDPLL\033[0m"


### HS

echo " "
echo "------------------------"
echo "  HORNSAT - $TOTALHS TESTS"
echo "------------------------"
echo "  Running $TOTALOKHS satisfiable tests with TIMEOUT=$TIMEOUT"
echo "------------------------"

for i in $OKHSFILES ; do
    echo -n "$i... " ;
    ret=$($CMD $i);
    if [ $? -eq 124 ];
    then
	timeout_hs=$((timeout_hs+1));
	echo -e "\033[0;33mTIMEOUT\033[0m";
    else
	if echo $ret | grep "true" > /dev/null;
	then
	    pass_hs=$((pass_hs+1));
	    echo -e "\033[0;32mSUCCESS\033[0m"
	elif echo $ret | grep "false" > /dev/null;
	then
	    wrong_hs=$((wrong_hs+1));
	    echo -e "\033[0;31mWRONG\033[0m";
	else
	    fail_hs=$((fail_hs+1));
	    echo -e "\033[0;36mFAIL\033[0m";
	fi;
    fi;
done;

echo ""
echo "------------------------"
echo "  Running $TOTALKOHS unsatisfiable tests with TIMEOUT=$TIMEOUT"
echo "------------------------"

for i in $KOHSFILES ; do
    echo -n "$i... " ;
    ret=$($CMD $i);
    if [ $? -eq 124 ];
    then
	timeout_hs=$((timeout_hs+1));
	echo -e "\033[0;33mTIMEOUT\033[0m";
    else
	if echo $ret | grep "true" > /dev/null;
	then
	    wrong_hs=$((wrong_hs+1));
	    echo -e "\033[0;31mWRONG\033[0m";
	elif echo $ret | grep "false" > /dev/null;
	then
	    pass_hs=$((pass_hs+1));
	    echo -e "\033[0;32mSUCCESS\033[0m"
	else
	    fail_hs=$((fail_hs+1));
	    echo -e "\033[0;36mFAIL\033[0m";
	fi;
    fi;
done;

echo "------------------------"
echo -e "\033[0;31mWrong  : $wrong_hs / $TOTALHS\033[0m"
echo -e "\033[0;32mPass   : $pass_hs / $TOTALHS\033[0m"
echo -e "\033[0;33mTimeout: $timeout_hs / $TOTALHS\033[0m"
echo -e "\033[0;36mFail   : $fail_hs / $TOTALHS\033[0m"



### XNF

echo " "
echo "------------------------"
echo "  XNF - $TOTALXNF TESTS"
echo "------------------------"
echo "  Running $TOTALOKXNF satisfiable tests with TIMEOUT=$TIMEOUT"
echo "------------------------"

for i in $OKXNFFILES ; do
    echo -n "$i... " ;
    ret=$($CMD $i);
    if [ $? -eq 124 ];
    then
	timeout_xnf=$((timeout_xnf+1));
	echo -e "\033[0;33mTIMEOUT\033[0m";
    else
	if echo $ret | grep "true" > /dev/null;
	then
	    pass_xnf=$((pass_xnf+1));
	    echo -e "\033[0;32mSUCCESS\033[0m"
	elif echo $ret | grep "false" > /dev/null;
	then
	    wrong_xnf=$((wrong_xnf+1));
	    echo -e "\033[0;31mWRONG\033[0m";
	else
	    fail_xnf=$((fail_xnf+1));
	    echo -e "\033[0;36mFAIL\033[0m";
	fi;
    fi;
done;

echo ""
echo "------------------------"
echo "  Running $TOTALKOXNF unsatisfiable tests with TIMEOUT=$TIMEOUT"
echo "------------------------"

for i in $KOXNFFILES ; do
    echo -n "$i... " ;
    ret=$($CMD $i);
    if [ $? -eq 124 ];
    then
	timeout_xnf=$((timeout_xnf+1));
	echo -e "\033[0;33mTIMEOUT\033[0m";
    else
	if echo $ret | grep "true" > /dev/null;
	then
	    wrong_xnf=$((wrong_xnf+1));
	    echo -e "\033[0;31mWRONG\033[0m";
	elif echo $ret | grep "false" > /dev/null;
	then
	    pass_xnf=$((pass_xnf+1));
	    echo -e "\033[0;32mSUCCESS\033[0m"
	else
	    fail_xnf=$((fail_xnf+1));
	    echo -e "\033[0;36mFAIL\033[0m";
	fi;
    fi;
done;

echo "------------------------"
echo -e "\033[0;31mWrong  : $wrong_xnf / $TOTALXNF\033[0m"
echo -e "\033[0;32mPass   : $pass_xnf / $TOTALXNF\033[0m"
echo -e "\033[0;33mTimeout: $timeout_xnf / $TOTALXNF\033[0m"
echo -e "\033[0;36mFail   : $fail_xnf / $TOTALXNF\033[0m"
exit 0