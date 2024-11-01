cmake_minimum_required(VERSION 3.28)
project(rocksdb_test)

set(CMAKE_CXX_STANDARD 17)

# Add executable
add_executable(rocksdb_test example.cpp)

# Specify the path to the RocksDB config
set(Rocksdb_DIR "/Users/edwinpaco/Documents/work/Nethermind/rocksdb/rocksdb/install/lib/cmake/rocksdb")
set(Snappy_DIR "/Users/edwinpaco/Documents/work/Nethermind/rocksdb/snappy/install/lib/cmake/Snappy")
#set(mimalloc_DIR "/Users/edwinpaco/Documents/work/Nethermind/rocksdb/mimalloc/install/lib/cmake/mimalloc-1.8")
#set(Jemalloc_DIR "/Users/edwinpaco/Documents/work/Nethermind/rocksdb/jemalloc/install")
#include_directories(${Jemalloc_DIR}/include)

# Find the RocksDB package
find_package(Rocksdb REQUIRED CONFIG COMPONENTS Rocksdb::rocksdb-shared)
#find_package(mimalloc REQUIRED CONFIG COMPONENTS mimalloc-static)

# Link RocksDB to your executable
target_link_libraries(rocksdb_test PRIVATE RocksDB::rocksdb-shared)
#target_link_libraries(rocksdb_test PRIVATE mimalloc-static RocksDB::rocksdb-shared)
#target_link_libraries(rocksdb_test PRIVATE ${Jemalloc_DIR}/lib/libjemalloc.a)
