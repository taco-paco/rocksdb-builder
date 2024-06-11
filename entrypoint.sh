#!/bin/bash

# Compile gflags
#readelf -r /lib/aarch64-linux-gnu/libgflags.a | egrep '(GOT|PLT|JU?MP_SLOT)'

#ls /lib/aarch64-linux-gnu/
ls /lib/aarch64-linux-gnu/cmake
exit

mkdir -p /repos/gflags/build
cd /repos/gflags/build

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/usr/local" -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
make
make install


# exit 0
# Repo for cmake artifacts
mkdir -p /repos/rocksdb/build
cd /repos/rocksdb/build

# librocksdb.so
# Create Makefile
cmake .. -DCMAKE_BUILD_TYPE=Release -DWITH_GFLAGS=ON -DWITH_LZ4=ON \
  -DWITH_ZLIB=ON -DWITH_SNAPPY=ON -DWITH_ZSTD=ON -DWITH_BZ2=ON \
  -DWITH_JEMALLOC=ON -DGFLAGS_SHARED=FALSE -DGFLAGS_NOTHREADS=FALSE  \
  -Dgflags_DIR="/usr/local/lib/cmake/gflags"

make

ldd ./librocksdb.so



