# HAECHI: SmartContract Security Diagnostic Tool

HAECHI automatically checks Smart Contracts for vulnerabilities and bad practices - it gives a detailed explanation of the problem.   
We already use it in our security audits.   

![image](https://github.com/byunghyun23/haechi/blob/master/haechi.png)

## Documents
* You can check the Korean version of the Solidity Secure Coding Guide and papers in the documnet directory.
```
Solidity Secure Coding Guide.pdf
Security Weakness Diagnostic Tool for Secure Smart Contract.pdf
```

## Requirements
* Windows or Linux
* solidity compiler 0.4.25 or 0.4.26

## Install (Only Linux)
* sudo snap install docker
* sudo docker pull ethereum/solc:0.4.25

## Run (Linux)
* The .sol file must exist in solidity_examples.
* ./haechi.sh [filename]

## Example (Linux)
* ./haechi.sh DoSAttack.sol

## Run (Windows)
* haechi.bat [filename]

## Example (Windows)
* haechi.bat solidity_examples/DoSAttack.sol
```
********** RULECHECK RESULTS **********   
   
========== DoSAttack ==========   
[CRITICAL] DoSAttack warning "Potential vulnerability to DoS attack", Line : 10   
   
========== None Access Modifier ==========   
None   
   
========== Overflow ==========   
Not yet implemented   
   
========== Underflow ==========   
Not yet implemented   
   
========== Reentrancy ==========   
None   
   
========== Reentrancy : Transfer Ether ==========   
None   
   
========== tx-origin ==========   
[MAJOR] tx-origin warning "Potential vulnerability to tx.origin attack", Line : 9   
   
========== Contract characteristics : Multiple Inheritance ==========   
None   
   
   
********** CRITICITY COUNT **********   
MAJOR : 1   
MINOR : 0   
CRITICAL : 1   
   
********** CONTEXT COUNT **********   
contract : 1   
variable : 3   
funcDef : 1   
funcCall : 2   
   
********** EXECUTION TIME **********   
scanning time : 0.009 sec   
parsing time : 0.010 sec   
emitting time : 0.109 sec   
ruleChecking time : 0.005 sec   
total time : 0.154 sec   
```
