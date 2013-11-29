#include "rocksdb/db.h"
#include "rocksdb/write_batch.h"

#ifndef RUBY_ROCKSDB_H
#define RUBY_ROCKSDB_H 1


extern "C" {

#include <ruby.h>
  extern VALUE cRocksdb_iterator;
  
  typedef VALUE (*METHOD)(...);
  
  struct rocksdb_pointer{ 
    rocksdb::DB* db;
  };

  struct rocksdb_iterator_pointer{ 
    rocksdb::Iterator* it;
  };
  
}
#endif
