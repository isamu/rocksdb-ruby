#include "rocksdb/db.h"
#include "rocksdb/write_batch.h"
#include <iostream>

extern "C" {

#include <stdio.h>
#include <ruby.h>
  
  typedef VALUE (*METHOD)(...);
  
  struct rocksdb_pointer{ 
    rocksdb::DB* db;
  };

  VALUE rocksdb_db_init(int argc, VALUE* argv, VALUE self);
  VALUE db_alloc(VALUE klass);
  VALUE rocksdb_db_put(VALUE self, VALUE v_key, VALUE v_value);
  VALUE rocksdb_db_write(VALUE self, VALUE v_write);
  VALUE rocksdb_db_get(VALUE self, VALUE v_key);
  VALUE rocksdb_db_multi_get(VALUE self, VALUE v_array);
  VALUE rocksdb_db_delete(VALUE self, VALUE v_key);
  VALUE rocksdb_db_close(VALUE self);

  VALUE rocksdb_write_batch_init();
  VALUE batch_alloc(VALUE klass);
  VALUE rocksdb_write_batch_put(VALUE self, VALUE v_key, VALUE v_value);
  VALUE rocksdb_write_batch_delete(VALUE self, VALUE v_key);
}
