#include "rocksdb/db.h"
#include "rocksdb/write_batch.h"
#include <iostream>

extern "C" {

#include <stdio.h>
#include <ruby.h>
  
  typedef VALUE (*METHOD)(...);
  
  VALUE rocksdb_db_init(int argc, VALUE* argv, VALUE self);
  VALUE rocksdb_db_put(VALUE self, VALUE v_key, VALUE v_value);
  VALUE rocksdb_db_write(VALUE self, VALUE v_write);
  VALUE rocksdb_db_get(VALUE self, VALUE v_key);
  VALUE rocksdb_db_multi_get(VALUE self, VALUE v_array);
  VALUE rocksdb_db_delete(VALUE self, VALUE v_key);
  VALUE rocksdb_db_close();

  VALUE rocksdb_write_batch_init();
  VALUE batch_alloc(VALUE klass);
  VALUE rocksdb_write_batch_put(VALUE self, VALUE v_key, VALUE v_value);
  VALUE rocksdb_write_batch_delete(VALUE self, VALUE v_key);
  
  rocksdb::DB* db;

  void Init_RocksDB(){
    
    VALUE cRocksdb;
    VALUE cRocksdb_db;
    VALUE cRocksdb_write_batch;
    
    cRocksdb = rb_define_class("RocksDB", rb_cObject);
    cRocksdb_db = rb_define_class_under(cRocksdb, "DB", rb_cObject);

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

  VALUE rocksdb_db_write(VALUE self, VALUE v_write){
    rocksdb::WriteBatch *batch;
    Data_Get_Struct(v_write, rocksdb::WriteBatch, batch);

    rocksdb::Status status = db->Write(rocksdb::WriteOptions(), batch);
    return status.ok() ? Qtrue : Qfalse;
  }

  VALUE rocksdb_db_get(VALUE self, VALUE v_key){
    Check_Type(v_key, T_STRING);

    std::string key = std::string((char*)RSTRING_PTR(v_key));
    std::string value;
    db->Get(rocksdb::ReadOptions(), key, &value);    

    return rb_str_new(value.data(), value.size());
  }


  VALUE rocksdb_db_multi_get(VALUE self, VALUE v_array){
    Check_Type(v_array, T_ARRAY);

    long i;
    VALUE *tmp = RARRAY_PTR(v_array);
    long length = RARRAY_LEN(v_array);
    std::vector<std::string> values(length);
    std::vector<rocksdb::Slice> keys(length);
    std::vector<rocksdb::Status> status;

    for(i=0; i < length; i++){
      keys[i] = rocksdb::Slice((char*)RSTRING_PTR(*tmp));
      tmp++;
    }

    status = db->MultiGet(rocksdb::ReadOptions(),keys,&values);
    for(i=0; i < length; i++){
      RARRAY_PTR(v_array)[i] = rb_str_new(values[i].data(), values[i].size());
    }
    return v_array;
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

  VALUE batch_alloc(VALUE klass){
    rocksdb::WriteBatch *batch = ALLOC(rocksdb::WriteBatch);
    batch = new rocksdb::WriteBatch;
    return Data_Wrap_Struct(klass, 0, -1, batch);
  }

  VALUE rocksdb_write_batch_init(){
    return Qtrue;
  }
  VALUE rocksdb_write_batch_put(VALUE self, VALUE v_key, VALUE v_value){
    Check_Type(v_key, T_STRING);
    Check_Type(v_value, T_STRING);

    rocksdb::WriteBatch *batch;
    std::string key = std::string((char*)RSTRING_PTR(v_key));
    std::string value = std::string((char*)RSTRING_PTR(v_value));
    
    Data_Get_Struct(self, rocksdb::WriteBatch, batch);
    batch->Put(key, value);
    return Qnil;
  }
  VALUE rocksdb_write_batch_delete(VALUE self, VALUE v_key){
    Check_Type(v_key, T_STRING);

    rocksdb::WriteBatch *batch;
    std::string key = std::string((char*)RSTRING_PTR(v_key));
    
    Data_Get_Struct(self, rocksdb::WriteBatch, batch);
    batch->Delete(key);

    return Qnil;
  }

}
