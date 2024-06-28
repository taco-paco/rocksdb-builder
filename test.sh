#!/bin/bash

docker build -t rocksdb-builder .
docker run --rm  --name rcks -v ./artifacts:/output rocksdb-builder

export LD_LIBRARY_PATH=./artifact/lib
g++ -o ./example example.cpp -L./artifacts/lib -lrocksdb -I./artifacts/include

./example
