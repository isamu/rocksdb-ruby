#include "rocksdb_batch_rb.h"

extern "C" {
#include <ruby.h>

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
