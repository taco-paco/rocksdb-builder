#include <iostream>
#include <rocksdb/db.h>

int main() {
    rocksdb::DB* db;
    rocksdb::Options options;
    options.create_if_missing = true;

    rocksdb::Status status = rocksdb::DB::Open(options, "/tmp/testdb", &db);
    if (!status.ok()) {
        std::cerr << "Unable to open/create test database '/tmp/testdb'" << std::endl;
        std::cerr << status.ToString() << std::endl;
        return 1;
    }

    std::cout << "RocksDB opened successfully!" << std::endl;

    delete db;
    return 0;
}

