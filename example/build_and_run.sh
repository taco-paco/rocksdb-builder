#!/bin/bash

docker build -t rocksdb-builder ..

ARTIFACTS_PATH="$(pwd)/artifacts"
docker run --rm  --name rcks -v $ARTIFACTS_PATH:/output rocksdb-builder

#export LD_LIBRARY_PATH=./artifacts/lib
#g++ -o ./rocksdb_example example.cpp -L./artifacts/lib -lrocksdb -I./artifacts/include
mkdir build && cd build
cmake -DRocksdb_ROOT=$ARTIFACTS_PATH -DCMAKE_BUILD_TYPE=Release ..
cmake --build .

./rocksdb_example
