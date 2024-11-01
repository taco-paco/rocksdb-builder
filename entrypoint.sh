#!/bin/bash

cp -r /tmp/rocksdb/* /output

# Just to play around
ldd /output/lib/librocksdb.so

#cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../install \
#-DWITH_GFLAGS=ON -DWITH_LZ4=ON -DWITH_ZLIB=ON \
#-DWITH_SNAPPY=ON -DWITH_ZSTD=ON -DWITH_BZ2=ON  \
#-DUSE_RTTI=ON \
#-DWITH_JEMALLOC=OFF -DWITH_MIMALLOC=ON \
#-DGFLAGS_SHARED=FALSE -DGFLAGS_NOTHREADS=FALSE  \
#-Dgflags_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/gflags/install/lib/cmake/gflags" \
#-DSnappy_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/snappy/install/lib/cmake/Snappy" \
#-Dmimalloc_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/mimalloc/install/lib/cmake/mimalloc-1.8"

#cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=../install \
#-DWITH_GFLAGS=ON -DWITH_LZ4=ON -DWITH_ZLIB=ON \
#-DWITH_SNAPPY=ON -DWITH_ZSTD=ON -DWITH_BZ2=ON  \
#-DUSE_RTTI=ON \
#-DWITH_JEMALLOC=OFF -DWITH_MIMALLOC=ON \
#-DGFLAGS_SHARED=FALSE -DGFLAGS_NOTHREADS=FALSE  \
#-Dmimalloc_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/mimalloc/install/lib/cmake/mimalloc-1.8" \
#-Dgflags_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/gflags/install/lib/cmake/gflags" \
#-DSnappy_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/snappy/install/lib/cmake/Snappy" \
#-Dzstd_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/zstd/build/cmake/install/lib/cmake/zstd" \
#-DZLIB_LIBRARY="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/zlib/install/lib/libz.a" \
#-DZLIB_INCLUDE_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/zlib/install/include" \
#-DBZIP2_LIBRARIES="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/bzip2/install/lib/libbz2_static.a" \
#-DBZIP2_INCLUDE_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/bzip2/install/include"
#
#
## rm -DSnappy_DIR use snappy_ROOT_DIR instead
#cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=../install \
#-DWITH_GFLAGS=ON -DWITH_LZ4=ON -DWITH_ZLIB=ON \
#-DWITH_SNAPPY=ON -DWITH_ZSTD=ON -DWITH_BZ2=ON  \
#-DUSE_RTTI=ON \
#-DWITH_JEMALLOC=OFF -DWITH_MIMALLOC=ON \
#-DGFLAGS_SHARED=FALSE -DGFLAGS_NOTHREADS=FALSE  \
#-Dmimalloc_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/mimalloc/install/lib/cmake/mimalloc-1.8" \
#-Dgflags_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/gflags/install/lib/cmake/gflags" \
#-Dsnappy_ROOT_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/snappy/install/" \
#-Dzstd_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/zstd/build/cmake/install/lib/cmake/zstd" \
#-DZLIB_LIBRARY="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/zlib/install/lib/libz.a" \
#-DZLIB_INCLUDE_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/zlib/install/include" \
#-DBZIP2_LIBRARIES="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/bzip2/install/lib/libbz2_static.a" \
#-DBZIP2_INCLUDE_DIR="/Users/edwinpaco/Documents/work/Nethermind/rocksdb/bzip2/install/include
