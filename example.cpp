#include <iostream>
#include <thread>
#include <chrono>

#include <rocksdb/db.h>
#include <rocksdb/convenience.h>
#include <rocksdb/options.h>
#include <rocksdb/memory_allocator.h>
#include <rocksdb/configurable.h>
//#include <jemalloc/jemalloc.h>

class CustomMemoryAllocator : public rocksdb::MemoryAllocator {
public:
    void* Allocate(size_t size) override {
        std::cout << "Allocate" << std::endl;
        return malloc(size);
    }

    void Deallocate(void* p) override {
        std::cout << "Deallocate" << std::endl;
        free(p);
    }

    const char* Name() const override {
        return "CustomMemoryAllocator";
    }
};


int main() {

    rocksdb::DB* db;
    rocksdb::Options options;
    options.create_if_missing = true;
//    options.compression = rocksdb::kSnappyCompression;

    rocksdb::LRUCacheOptions cache_opts;

    std::shared_ptr<CustomMemoryAllocator> custom_allocator(new CustomMemoryAllocator());
    cache_opts.memory_allocator = custom_allocator;
    std::shared_ptr<rocksdb::Cache> cache = rocksdb::NewLRUCache(cache_opts);

    rocksdb::BlockBasedTableOptions table_options;
    table_options.block_cache = cache;

    options.table_factory.reset(rocksdb::NewBlockBasedTableFactory(table_options));

//    {
//        rocksdb::JemallocAllocatorOptions jopts;
//        std::shared_ptr<rocksdb::MemoryAllocator> allocator;
//
//        jopts.limit_tcache_size = true;
//        jopts.tcache_size_lower_bound = 2 * 1024;
//        jopts.tcache_size_upper_bound = 1024;
//
//        rocksdb::Status s = NewJemallocNodumpAllocator(jopts, &allocator);
//    }
//
//    rocksdb::MemoryAllocator::CreateFromString(   rocksdb::ConfigOptions{}, "", nullptr);

    std::this_thread::sleep_for(std::chrono::seconds(20));
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

//
//    // Jemalloc test code
//    uint64_t allocated = 0;
//    size_t allocated_size = sizeof(allocated);
//    if (::je_mallctl("stats.allocated", &allocated, &allocated_size, NULL, 0) == 0) {
//        std::cout << "Allocated memory: " << allocated << " bytes" << std::endl;
//    } else {
//        std::cerr << "Failed to get allocated memory stats from jemalloc" << std::endl;
//    }

    return 0;
}
