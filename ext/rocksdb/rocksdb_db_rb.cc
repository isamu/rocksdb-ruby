#include "rocksdb_rb.h"
#include "rocksdb_db_rb.h"
#include "ruby/encoding.h"
#include <iostream>

extern "C" {
#include <ruby.h>

  VALUE rocksdb_db_init(VALUE self, VALUE v_db_path, VALUE v_readonly, VALUE v_db_options) {
    rocksdb_pointer* db_pointer;
    rocksdb::DB* db;
    rocksdb::Options options;
    rocksdb::Status status;

    std::string db_file_name;
    std::string db_string_options;

    Data_Get_Struct(self, rocksdb_pointer, db_pointer);

    // Initialize db_pointer
    db_pointer->db = nullptr;
    db_pointer->readonly = false;

    bool readonly = RTEST(v_readonly);

    db_file_name = STRING_FROM_RB_VALUE(v_db_path);
    db_string_options = STRING_FROM_RB_VALUE(v_db_options);

    // Set option before parsing string, so create_if_missing could be
    // overwriten in option string
    options.create_if_missing = true;
    status = GetOptionsFromString(options, db_string_options, &options);

    if(!status.ok()) {
      raise_status_error(&status);
      return Qnil;
    }

    if(readonly){
      status = rocksdb::DB::OpenForReadOnly(options, db_file_name, &db);
    }else{
      status = rocksdb::DB::Open(options, db_file_name, &db);
    }

    db_pointer->db = db;
    db_pointer->readonly = readonly;

    if(!status.ok()) {
      raise_status_error(&status);
      return Qnil;
    }

    return Qtrue;
  }

  VALUE db_alloc(VALUE klass){
    rocksdb_pointer* db_pointer = ALLOC(rocksdb_pointer);
    return Data_Wrap_Struct(klass, 0, db_free, db_pointer);
  }

  void db_free(rocksdb_pointer* db_pointer){
    if(db_pointer == nullptr) {
      return;
    }

    if(db_pointer->db != nullptr){
      delete db_pointer->db;
      db_pointer->db = nullptr;
    }

    delete db_pointer;
    db_pointer = nullptr;
  }

  VALUE rocksdb_db_close(VALUE self){
    rocksdb_pointer* db_pointer = get_db(&self);

    if(db_pointer == nullptr) {
      return Qfalse;
    }

    if(db_pointer->db != nullptr){
      delete db_pointer->db;
      db_pointer->db = nullptr;
    }

    return Qtrue;
  }

  VALUE rocksdb_db_put(VALUE self, VALUE v_key, VALUE v_value) {
    rocksdb_pointer* db_pointer = get_db_for_write(&self);

    rocksdb::Slice key = SLICE_FROM_RB_VALUE(v_key);
    std::string value = STRING_FROM_RB_VALUE(v_value);

    rocksdb::Status status = db_pointer->db->Put(rocksdb::WriteOptions(), key, value);

    if(!status.ok()) {
      raise_status_error(&status);
      return Qnil;
    }

    return Qtrue;
  }

  VALUE rocksdb_db_write(VALUE self, VALUE v_write){
    rocksdb_pointer* db_pointer = get_db_for_write(&self);

    rocksdb::WriteBatch *batch;
    Data_Get_Struct(v_write, rocksdb::WriteBatch, batch);

    rocksdb::Status status = db_pointer->db->Write(rocksdb::WriteOptions(), batch);

    if(!status.ok()) {
      raise_status_error(&status);
      return Qnil;
    }

    return Qtrue;
  }

  VALUE rocksdb_db_property(VALUE self, VALUE v_key){
    rocksdb_pointer* db_pointer = get_db_for_read(&self);

    rocksdb::Slice key = SLICE_FROM_RB_VALUE(v_key);
    std::string value = std::string();

    bool result_ok = db_pointer->db->GetProperty(key, &value);

    if(!result_ok) return Qnil;
    return SLICE_TO_RB_STRING(value);
  }

  VALUE rocksdb_db_options(VALUE self){
    rocksdb_pointer* db_pointer = get_db_for_read(&self);

    VALUE v_result = rb_hash_new();
    VALUE v_key = Qnil;
    VALUE v_value = Qnil;

    std::string options_str;
    std::unordered_map<std::string, std::string> options_map;

    GetStringFromDBOptions(&options_str, db_pointer->db->GetOptions());

    v_key = rb_str_new_cstr("DBOptions");
    v_value = rb_str_new_cstr(options_str.c_str());
    rb_hash_aset(v_result, v_key, v_value);

    GetStringFromColumnFamilyOptions(&options_str, db_pointer->db->GetOptions());

    v_key = rb_str_new_cstr("CFOptions");
    v_value = rb_str_new_cstr(options_str.c_str());
    rb_hash_aset(v_result, v_key, v_value);

    return v_result;
  }

  VALUE rocksdb_db_get(VALUE self, VALUE v_key){
    rocksdb_pointer* db_pointer = get_db_for_read(&self);

    rocksdb::Slice key = SLICE_FROM_RB_VALUE(v_key);
    std::string value;

    rocksdb::Status status = db_pointer->db->Get(rocksdb::ReadOptions(), key, &value);

    if(status.IsNotFound()) {
      return Qnil;
    } else if (!status.ok()) {
      raise_status_error(&status);
      return Qnil;
    }

    return SLICE_TO_RB_STRING(value);
  }

  VALUE rocksdb_db_multi_get(VALUE self, VALUE v_array){
    Check_Type(v_array, T_ARRAY);

    rocksdb_pointer* db_pointer =  get_db_for_read(&self);

    long i;
    long length = RARRAY_LEN(v_array);
    std::vector<std::string> values(length);
    std::vector<rocksdb::Slice> keys(length);
    std::vector<rocksdb::Status> statuses;

    for(i=0; i < length; i++){
      VALUE v_element = rb_ary_entry(v_array, i);
      keys[i] = SLICE_FROM_RB_VALUE(v_element);
    }

    statuses = db_pointer->db->MultiGet(rocksdb::ReadOptions(), keys, &values);

    for(i=0; i < length; i++){
      rocksdb::Status status = statuses[i];

      if(status.IsNotFound()) {
        rb_ary_store(v_array, i, Qnil);
      } else if(status.ok()) {
        rb_ary_store(v_array, i, SLICE_TO_RB_STRING(values[i]));
      } else {
        rb_ary_store(v_array, i, Qfalse);
      }
    }

    return v_array;
  }

  VALUE rocksdb_db_delete(VALUE self, VALUE v_key){
    rocksdb_pointer* db_pointer = get_db_for_write(&self);

    rocksdb::Slice key = SLICE_FROM_RB_VALUE(v_key);
    rocksdb::Status status = db_pointer->db->Delete(rocksdb::WriteOptions(), key);

    // https://github.com/facebook/rocksdb/issues/4975
    if (status.ok()) {
      return Qtrue;
    } else {
      raise_status_error(&status);
      return Qfalse;
    }
  }

  VALUE rocksdb_db_exists(VALUE self, VALUE v_key){
    rocksdb_pointer* db_pointer = get_db_for_read(&self);

    rocksdb::Slice key = SLICE_FROM_RB_VALUE(v_key);
    std::string value = std::string();

    return db_pointer->db->KeyMayExist(rocksdb::ReadOptions(), key, &value) ? Qtrue : Qfalse;
  }


  VALUE rocksdb_db_to_iterator(VALUE self){
    rocksdb_pointer* db_pointer = get_db_for_read(&self);
    rocksdb_iterator_pointer* rocksdb_it;

    rocksdb::Iterator* it = db_pointer->db->NewIterator(rocksdb::ReadOptions());

    VALUE klass;
    klass = rb_class_new_instance(0, NULL, cRocksdb_iterator);

    Data_Get_Struct(klass, rocksdb_iterator_pointer , rocksdb_it);
    rocksdb_it->it = it;
    rocksdb_it->db_pointer = db_pointer;

    return klass;
  }

  VALUE rocksdb_db_debug(VALUE self){
    return Qnil;
  }

  VALUE rocksdb_db_is_writable(VALUE self){
    rocksdb_pointer* db_pointer = get_db(&self);

    return (db_pointer->readonly) ? Qfalse : Qtrue;
  }

  VALUE rocksdb_db_is_open(VALUE self){
    rocksdb_pointer* db_pointer = get_db(&self);

    return (db_pointer->db == NULL) ? Qfalse : Qtrue;
  }

  VALUE rocksdb_db_compact(int argc, VALUE* argv, VALUE self) {
    VALUE v_from, v_to;
    rocksdb::Slice from, to;

    rb_scan_args(argc, argv, "02", &v_from, &v_to);

    if(!NIL_P(v_from)) {
      from = SLICE_FROM_RB_VALUE(v_from);
    }

    if(!NIL_P(v_to)) {
      to = SLICE_FROM_RB_VALUE(v_to);
    }

    rocksdb_pointer* db_pointer = get_db_for_read(&self);
    rocksdb::Status status = db_pointer->db->CompactRange(rocksdb::CompactRangeOptions(), &from, &to);

    return status.ok() ? Qtrue : Qfalse;
  }

  VALUE raise_status_error(rocksdb::Status *status) {
    char const *error_text = status->ToString().c_str();
    rb_raise(cRocksdb_status_error, "%s", error_text);

    return Qnil;
  }

  rocksdb_pointer* get_db(VALUE *self) {
    rocksdb_pointer *db_pointer;
    Data_Get_Struct(*self, rocksdb_pointer, db_pointer);

    return db_pointer;
  }

  rocksdb_pointer* get_db_for_read(VALUE *self) {
    rocksdb_pointer *db_pointer = get_db(self);

    check_is_db_ready(db_pointer);

    return db_pointer;
  }

  rocksdb_pointer* get_db_for_write(VALUE *self) {
    rocksdb_pointer *db_pointer = get_db(self);

    check_is_db_ready(db_pointer);

    if (db_pointer->readonly) {
      rb_raise(cRocksdb_readonly, "database is read-only");
    }

    return db_pointer;
  }

  void check_is_db_ready(rocksdb_pointer *db_pointer) {
    if (db_pointer == NULL) {
      rb_raise(cRocksdb_database_closed, "database is not initialized");
    }

    if (db_pointer->db == NULL) {
      rb_raise(cRocksdb_database_closed, "database is not opened");
    }
  }
}
