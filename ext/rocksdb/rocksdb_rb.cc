#include "rocksdb_rb.h"
#include "rocksdb_db_rb.h"
#include "rocksdb_batch_rb.h"
#include "rocksdb_status_rb.h"
#include "rocksdb_iterator_rb.h"

extern "C" {
  VALUE cRocksdb_iterator;

  void Init_RocksDB(){
   
    VALUE cRocksdb;
    VALUE cRocksdb_db;
    VALUE cRocksdb_write_batch;
    VALUE cRocksdb_read_options;
    VALUE cRocksdb_write_options;
    VALUE cRocksdb_status;
    
    cRocksdb = rb_define_module("RocksDB");
    cRocksdb_db = rb_define_class_under(cRocksdb, "DB", rb_cObject);
    rb_define_alloc_func(cRocksdb_db, db_alloc);

    rb_define_private_method(cRocksdb_db, "__initialize", (METHOD)rocksdb_db_init, -1);
    rb_define_private_method(cRocksdb_db, "__initialize2", (METHOD)rocksdb_db_init2, -1);
    rb_define_method(cRocksdb_db, "put", (METHOD)rocksdb_db_put, 2);
    rb_define_method(cRocksdb_db, "write", (METHOD)rocksdb_db_write, 1);
    rb_define_method(cRocksdb_db, "get", (METHOD)rocksdb_db_get, 1);
    rb_define_method(cRocksdb_db, "multi_get", (METHOD)rocksdb_db_multi_get, 1);
    rb_define_method(cRocksdb_db, "delete", (METHOD)rocksdb_db_delete, 1);
    rb_define_method(cRocksdb_db, "exists?", (METHOD)rocksdb_db_exists, 1);
    rb_define_private_method(cRocksdb_db, "__close", (METHOD)rocksdb_db_close, 0);
    rb_define_method(cRocksdb_db, "debug", (METHOD)rocksdb_db_debug, 0);
    rb_define_method(cRocksdb_db, "new_iterator", (METHOD)rocksdb_db_new_iterator, 0);
    rb_define_method(cRocksdb_db, "compact", (METHOD)rocksdb_db_compact, -1);

    rb_define_method(cRocksdb_db, "iterator", (METHOD)rocksdb_db_each, 0);
    rb_define_method(cRocksdb_db, "each_index", (METHOD)rocksdb_db_each_index, 0);
    rb_define_method(cRocksdb_db, "each_with_index", (METHOD)rocksdb_db_each_with_index, 0);
    rb_define_method(cRocksdb_db, "reverse_each", (METHOD)rocksdb_db_reverse_each, 0);

    cRocksdb_write_batch = rb_define_class_under(cRocksdb, "Batch", rb_cObject);
    rb_define_alloc_func(cRocksdb_write_batch, batch_alloc);
    rb_define_private_method(cRocksdb_write_batch, "initialize", (METHOD)rocksdb_write_batch_init, 0);
    rb_define_method(cRocksdb_write_batch, "put", (METHOD)rocksdb_write_batch_put, 2);
    rb_define_method(cRocksdb_write_batch, "delete", (METHOD)rocksdb_write_batch_delete, 1);

    cRocksdb_iterator = rb_define_class_under(cRocksdb, "Iterator", rb_cObject);
    rb_define_alloc_func(cRocksdb_iterator, rocksdb_iterator_alloc);
    rb_define_method(cRocksdb_iterator, "seek_to_first", (METHOD)rocksdb_iterator_seek_to_first, 0);
    rb_define_method(cRocksdb_iterator, "seek_to_last", (METHOD)rocksdb_iterator_seek_to_last, 0);
    rb_define_method(cRocksdb_iterator, "seek", (METHOD)rocksdb_iterator_seek, 1);
    rb_define_method(cRocksdb_iterator, "valid", (METHOD)rocksdb_iterator_valid, 0);
    rb_define_method(cRocksdb_iterator, "key", (METHOD)rocksdb_iterator_key, 0);
    rb_define_method(cRocksdb_iterator, "value", (METHOD)rocksdb_iterator_value, 0);
    rb_define_method(cRocksdb_iterator, "next", (METHOD)rocksdb_iterator_next, 0);
    rb_define_method(cRocksdb_iterator, "close", (METHOD)rocksdb_iterator_close, 0);

    cRocksdb_status = rb_define_class_under(cRocksdb, "Status", rb_cObject);
    cRocksdb_read_options = rb_define_class_under(cRocksdb, "ReadOptions", rb_cObject);
    cRocksdb_write_options = rb_define_class_under(cRocksdb, "WriteOptions", rb_cObject);

  }
}
