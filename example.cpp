#include <iostream>
#include <rocksdb/db.h>
#include <rocksdb/options.h>

int main() {
    rocksdb::DB* db;
    rocksdb::Options options;
    options.create_if_missing = true;
    options.compression = rocksdb::kSnappyCompression;

    rocksdb::Status status = rocksdb::DB::Open(options, "/tmp/testdb", &db);
    if (!status.ok()) {
        std::cerr << "Unable to open/create test database '/tmp/testdb'" << std::endl;
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
