#!/bin/bash
sudo docker run --rm -v $(pwd):/sources ethereum/solc:0.4.25 --overwrite --ast-compact-json /sources/solidity_examples/$1 -o /sources/solidity_examples
java -jar dist/haechi.jar $(pwd)/solidity_examples/$1
