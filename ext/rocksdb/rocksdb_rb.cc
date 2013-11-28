#include "rocksdb_rb.h"
#include "rocksdb_db_rb.h"
#include "rocksdb_batch_rb.h"
#include "rocksdb_status_rb.h"

extern "C" {
  void Init_RocksDB(){
    
    VALUE cRocksdb;
    VALUE cRocksdb_db;
    VALUE cRocksdb_write_batch;
    VALUE cRocksdb_status;
    VALUE cRocksdb_read_options;
    VALUE cRocksdb_write_options;
    VALUE cRocksdb_iterator;
    
    cRocksdb = rb_define_class("RocksDB", rb_cObject);
    cRocksdb_db = rb_define_class_under(cRocksdb, "DB", rb_cObject);
    rb_define_alloc_func(cRocksdb_db, db_alloc);

    rb_define_private_method(cRocksdb_db, "initialize", (METHOD)rocksdb_db_init, -1);
    rb_define_method(cRocksdb_db, "put", (METHOD)rocksdb_db_put, 2);
    rb_define_method(cRocksdb_db, "write", (METHOD)rocksdb_db_write, 1);
    rb_define_method(cRocksdb_db, "get", (METHOD)rocksdb_db_get, 1);
    rb_define_method(cRocksdb_db, "multi_get", (METHOD)rocksdb_db_multi_get, 1);
    rb_define_method(cRocksdb_db, "delete", (METHOD)rocksdb_db_delete, 1);
    rb_define_method(cRocksdb_db, "close", (METHOD)rocksdb_db_close, 0);

    cRocksdb_write_batch = rb_define_class_under(cRocksdb, "Batch", rb_cObject);
    rb_define_alloc_func(cRocksdb_write_batch, batch_alloc);
    rb_define_private_method(cRocksdb_write_batch, "initialize", (METHOD)rocksdb_write_batch_init, 0);
    rb_define_method(cRocksdb_write_batch, "put", (METHOD)rocksdb_write_batch_put, 2);
    rb_define_method(cRocksdb_write_batch, "delete", (METHOD)rocksdb_write_batch_delete, 1);

    cRocksdb_status = rb_define_class_under(cRocksdb, "Status", rb_cObject);
    cRocksdb_read_options = rb_define_class_under(cRocksdb, "ReadOptions", rb_cObject);
    cRocksdb_write_options = rb_define_class_under(cRocksdb, "WriteOptions", rb_cObject);
    cRocksdb_iterator = rb_define_class_under(cRocksdb, "Iterator", rb_cObject);

  }
}
