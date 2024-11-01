cmake_minimum_required(VERSION 3.28)
project(rocksdb_example)

set(CMAKE_CXX_STANDARD 17)

# Find rocksdb
#set(Rocksdb_DIR "/Users/edwinpaco/Documents/work/Nethermind/rocksdb/rocksdb/install/lib/cmake/rocksdb")
find_package(Rocksdb CONFIG COMPONENTS Rocksdb::rocksdb-shared)

# Add executable
add_executable(rocksdb_example example.cpp)
target_link_libraries(rocksdb_example PRIVATE RocksDB::rocksdb-shared)
