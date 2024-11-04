cmake_minimum_required(VERSION 3.25.1)
project(rocksdb_example)

set(CMAKE_CXX_STANDARD 17)

add_library(RocksDB::rocksdb-shared SHARED IMPORTED)
set_target_properties(RocksDB::rocksdb-shared PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Rocksdb_ROOT}/include"
)

if(APPLE)
    set_property(TARGET RocksDB::rocksdb-shared APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
    set_target_properties(RocksDB::rocksdb-shared PROPERTIES
            IMPORTED_LOCATION_DEBUG "${Rocksdb_ROOT}/lib/librocksdb.9.4.0.dylib"
            IMPORTED_SONAME_DEBUG "@rpath/librocksdb.9.dylib"
    )
endif ()

if (UNIX AND NOT APPLE)
    set_property(TARGET RocksDB::rocksdb-shared APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
    set_target_properties(RocksDB::rocksdb-shared PROPERTIES
            IMPORTED_LOCATION_DEBUG "${Rocksdb_ROOT}/lib/librocksdb.so.9.4.0"
            IMPORTED_SONAME_DEBUG "@rpath/librocksdb.so.9"
    )
endif ()

execute_process(COMMAND ls /tmp/rocksdb/lib/
        RESULT_VARIABLE LS_RESULT)
message(STATUS "Library check result: ${LS_RESULT}")

# Add executable
add_executable(rocksdb_example example.cpp)
target_link_libraries(rocksdb_example PRIVATE RocksDB::rocksdb-shared)
