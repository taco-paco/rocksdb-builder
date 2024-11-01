#!/bin/bash

docker build -t rocksdb-builder ..
docker run --rm  --name rcks -v ./artifacts:/output rocksdb-builder

export LD_LIBRARY_PATH=./artifacts/lib
g++ -o ./rocksdb_example example.cpp -L./artifacts/lib -lrocksdb -I./artifacts/include
#mkdir build && cd build
#cmake -DRocksdb_DIR="artifacts/lib/cmake/rocksdb" -DCMAKE_BUIlD_TYPE=Release ..
#cmake --build .

./rocksdb_example
