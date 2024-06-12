#!/bin/bash

#readelf -r /lib/aarch64-linux-gnu/libgflags.a | egrep '(GOT|PLT|JU?MP_SLOT)'
#ls /lib/aarch64-linux-gnu/cmake/zstd/
#cat /lib/aarch64-linux-gnu/cmake/zstd/zstdConfig.cmake
#cat /lib/aarch64-linux-gnu/cmake/zstd/zstdTargets-none.cmake

#/usr/lib/aarch64-linux-gnu/libsnappy.a
#/usr/lib/aarch64-linux-gnu/libzstd.a

#readelf -r /usr/lib/aarch64-linux-gnu/libjemalloc.a |  egrep '(GOT|PLT|JU?MP_SLOT)'
#exit

# Compile gflags
mkdir -p /repos/gflags/build
cd /repos/gflags/build

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/usr/local" -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
make
make install

# Compile snappy
mkdir -p /repos/snappy/build
cd /repos/snappy/build

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/usr/local" -DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON

make -j4
make install

#readelf -r /usr/local/lib/libsnappy.a | egrep '(GOT|PLT|JU?MP_SLOT)'

# Compile zstd
mkdir -p /repos/zstd/build/cmake/build
cd /repos/zstd/build/cmake/build

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/usr/local" -DZSTD_BUILD_SHARED=OFF -DZSTD_BUILD_STATIC=ON

make -j4
make install

# Compile jemalloc
cd /repos/jemalloc
./autogen.sh
CFLAGS="-fPIC" ./configure --prefix=/usr

make build_lib_static
make install_lib_static
make install_include

# Compile rocketsdb
# exit 0
# Repo for cmake artifacts
mkdir -p /repos/rocksdb/build
cd /repos/rocksdb/build

# librocksdb.so
# Create Makefile
cmake .. -DCMAKE_BUILD_TYPE=Release -DWITH_GFLAGS=ON -DWITH_LZ4=ON \
  -DWITH_ZLIB=ON -DWITH_SNAPPY=ON -DWITH_ZSTD=ON -DWITH_BZ2=ON \
  -DWITH_JEMALLOC=ON -DGFLAGS_SHARED=FALSE -DGFLAGS_NOTHREADS=FALSE  \
  -Dgflags_DIR="/usr/local/lib/cmake/gflags" \
  -DSnappy_DIR="/usr/local/lib/cmake/Snappy" \
  -Dzstd_DIR="/usr/local/lib/cmake/zstd"

make -j4

ldd ./librocksdb.so



