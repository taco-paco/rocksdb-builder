#include <iostream>
#include <thread>

#include <rocksdb/db.h>
#include <rocksdb/convenience.h>
#include <rocksdb/options.h>
#include <rocksdb/configurable.h>


// Custom implementation of rocksdb::MemoryAllocator:
// https://github.com/darionyaphet/deep_into_rocksdb/blob/e5439aaaf6359bc1db74370c302b8cec9b8f4479/custom_memory_allocator.cpp#L8

// .NET and allocators. which one it uses? haw does it allocate
// TODO: instead of preloading rocksdb, we can preload allocator
int main() {
    rocksdb::DB* db;
    rocksdb::Options options;
    options.create_if_missing = true;

    rocksdb::Status status = rocksdb::DB::Open(options, "./testdb", &db);
    if (!status.ok()) {
        std::cerr << "Unable to open/create test database ',/testdb'" << std::endl;
        std::cerr << status.ToString() << std::endl;
        return 1;
    }

    std::cout << "RocksDB opened successfully with Snappy compression!" << std::endl;

    std::string key = "key";
    std::string value = "value";
    status = db->Put(rocksdb::WriteOptions(), key, value);
    if (!status.ok()) {
        std::cerr << "Failed to write data to RocksDB" << std::endl;
        std::cerr << status.ToString() << std::endl;
        delete db;
        return 1;
    }

    std::string retrieved_value;
    status = db->Get(rocksdb::ReadOptions(), key, &retrieved_value);
    if (!status.ok()) {
        std::cerr << "Failed to read data from RocksDB" << std::endl;
        std::cerr << status.ToString() << std::endl;
        delete db;
        return 1;
    }

    std::cout << "Read value: " << retrieved_value << std::endl;

    delete db;

    return 0;
}
