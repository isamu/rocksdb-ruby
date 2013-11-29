#include "rocksdb_rb.h"
#include "rocksdb_batch_rb.h"
#include "ruby/encoding.h"
#include <iostream>

extern "C" {
#include <ruby.h>

  VALUE rocksdb_iterator_seek_to_first(VALUE klass){
    rocksdb_iterator_pointer* rocksdb_it;
    Data_Get_Struct(klass, rocksdb_iterator_pointer , rocksdb_it);
    rocksdb_it->it->SeekToFirst();

    return Qnil;
  }
  VALUE rocksdb_iterator_alloc(VALUE klass){
    rocksdb_iterator_pointer* it = ALLOC(rocksdb_iterator_pointer);
    return Data_Wrap_Struct(klass, 0, -1, it);
  }

  VALUE rocksdb_iterator_valid(VALUE klass){
    rocksdb_iterator_pointer* rocksdb_it;
    Data_Get_Struct(klass, rocksdb_iterator_pointer , rocksdb_it);
    return rocksdb_it->it->Valid() ? Qtrue : Qfalse;
  }

  VALUE rocksdb_iterator_key(VALUE klass){
    rocksdb_iterator_pointer* rocksdb_it;
    std::string value;

    Data_Get_Struct(klass, rocksdb_iterator_pointer , rocksdb_it);
    value = rocksdb_it->it->key().ToString();

    return rb_enc_str_new(value.data(), value.size(), rb_utf8_encoding());
  }
  
  VALUE rocksdb_iterator_value(VALUE klass){
    rocksdb_iterator_pointer* rocksdb_it;
    std::string value;

    Data_Get_Struct(klass, rocksdb_iterator_pointer , rocksdb_it);
    value = rocksdb_it->it->value().ToString();

    return rb_enc_str_new(value.data(), value.size(), rb_utf8_encoding());

  }
  
  VALUE rocksdb_iterator_next(VALUE klass){
    rocksdb_iterator_pointer* rocksdb_it;
    Data_Get_Struct(klass, rocksdb_iterator_pointer , rocksdb_it);
    rocksdb_it->it->Next();

    return Qnil;
  }

  VALUE rocksdb_iterator_close(VALUE klass){
    rocksdb_iterator_pointer* rocksdb_it;
    Data_Get_Struct(klass, rocksdb_iterator_pointer , rocksdb_it);
    delete rocksdb_it->it;

    return Qnil;
  }
}
