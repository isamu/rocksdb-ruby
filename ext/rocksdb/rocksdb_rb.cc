#include "rocksdb/db.h"
#include <iostream>

extern "C" {

#include <stdio.h>
#include <ruby.h>
  
  typedef VALUE (*METHOD)(...);
  
  VALUE rocksdb_db_init(int argc, VALUE* argv, VALUE self);
  VALUE rocksdb_db_put(VALUE self, VALUE v_key, VALUE v_value);
  VALUE rocksdb_db_get(VALUE self, VALUE v_key);
  VALUE rocksdb_db_delete(VALUE self, VALUE v_key);
  VALUE rocksdb_db_close();
  
  
  rocksdb::DB* db;

  void Init_RocksDB(){
    
    VALUE cRocksdb;
    VALUE cRocksdb_db;
    
    cRocksdb = rb_define_class("RocksDB", rb_cObject);
    cRocksdb_db = rb_define_class_under(cRocksdb, "DB", rb_cObject);


    
    rb_define_private_method(cRocksdb_db, "initialize", (METHOD)rocksdb_db_init, -1);
    rb_define_method(cRocksdb_db, "put", (METHOD)rocksdb_db_put, 2);
    rb_define_method(cRocksdb_db, "get", (METHOD)rocksdb_db_get, 1);
    rb_define_method(cRocksdb_db, "delete", (METHOD)rocksdb_db_delete, 1);
    rb_define_method(cRocksdb_db, "close", (METHOD)rocksdb_db_close, 0);
  }
  
  VALUE rocksdb_db_init(int argc, VALUE* argv, VALUE self) {
    VALUE v_db_file_name;

    rb_scan_args(argc, argv, "01", &v_db_file_name);
    Check_Type(v_db_file_name, T_STRING);
    std::string db_file_name = std::string((char*)RSTRING_PTR(v_db_file_name));
    
    rocksdb::Options options;
    options.create_if_missing = true;
    rocksdb::Status status = rocksdb::DB::Open(options, db_file_name, &db);

    return status.ok() ? Qtrue : Qfalse;
  }

  VALUE rocksdb_db_put(VALUE self, VALUE v_key, VALUE v_value) {
    Check_Type(v_key, T_STRING);
    Check_Type(v_value, T_STRING);

    std::string key = std::string((char*)RSTRING_PTR(v_key));
    std::string value = std::string((char*)RSTRING_PTR(v_value));

    rocksdb::Status status = db->Put(rocksdb::WriteOptions(), key, value);
    
    return status.ok() ? Qtrue : Qfalse;
  }

  VALUE rocksdb_db_get(VALUE self, VALUE v_key){
    Check_Type(v_key, T_STRING);

    std::string key = std::string((char*)RSTRING_PTR(v_key));
    std::string value;
    db->Get(rocksdb::ReadOptions(), key, &value);    

    return rb_str_new(value.data(), value.size());
  }

  VALUE rocksdb_db_delete(VALUE self, VALUE v_key){
    Check_Type(v_key, T_STRING);

    std::string key = std::string((char*)RSTRING_PTR(v_key));
    rocksdb::Status status = db->Delete(rocksdb::WriteOptions(), key);

    return status.ok() ? Qtrue : Qfalse;
  }

  VALUE rocksdb_db_close(){
    delete db;
    return Qnil;
  }
}
