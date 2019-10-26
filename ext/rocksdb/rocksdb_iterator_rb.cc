#include "rocksdb_rb.h"
#include "rocksdb_batch_rb.h"
#include "rocksdb_iterator_rb.h"
#include "ruby/encoding.h"
#include <iostream>

extern "C" {
#include <ruby.h>
  VALUE rocksdb_iterator_alloc(VALUE klass){
    rocksdb_iterator_pointer* pointer = ALLOC(rocksdb_iterator_pointer);
    pointer->it = NULL;
    return Data_Wrap_Struct(klass, 0, -1, pointer);
  }

  VALUE rocksdb_iterator_seek_to_first(VALUE klass){
    rocksdb_iterator_pointer* pointer = get_iterator_for_read(&klass);

    pointer->it->SeekToFirst();

    return Qtrue;
  }

  VALUE rocksdb_iterator_seek_to_last(VALUE klass){
    rocksdb_iterator_pointer* pointer = get_iterator_for_read(&klass);
    pointer->it->SeekToLast();

    return Qtrue;
  }

  VALUE rocksdb_iterator_seek(VALUE klass, VALUE v_target){
    rocksdb_iterator_pointer* pointer = get_iterator_for_read(&klass);

    rocksdb::Slice target = SLICE_FROM_RB_VALUE(v_target);
    pointer->it->Seek(target);

    return Qtrue;
  }

  VALUE rocksdb_iterator_seek_prev(VALUE klass, VALUE v_target){
    rocksdb_iterator_pointer* pointer = get_iterator_for_read(&klass);

    rocksdb::Slice target = SLICE_FROM_RB_VALUE(v_target);

    pointer->it->SeekForPrev(target);

    return Qtrue;
  }

  VALUE rocksdb_iterator_valid(VALUE klass){
    rocksdb_iterator_pointer* pointer = get_iterator(&klass);

    if(pointer != NULL && pointer->it != NULL) {
      return pointer->it->Valid() ? Qtrue : Qfalse;
    }

    // Return falsey Qnil to indicate that iterator is closed
    return Qnil;
  }

  VALUE rocksdb_iterator_key(VALUE klass){
    rocksdb_iterator_pointer* pointer = get_iterator_for_read(&klass);

    std::string value = pointer->it->key().ToString();

    return SLICE_TO_RB_STRING(value);
  }

  VALUE rocksdb_iterator_value(VALUE klass){
    rocksdb_iterator_pointer* pointer = get_iterator_for_read(&klass);

    std::string value = pointer->it->value().ToString();

    return SLICE_TO_RB_STRING(value);
  }

  VALUE rocksdb_iterator_next(VALUE klass){
    rocksdb_iterator_pointer* pointer = get_iterator_for_read(&klass);

    pointer->it->Next();

    return Qtrue;
  }

  VALUE rocksdb_iterator_prev(VALUE klass){
    rocksdb_iterator_pointer* pointer = get_iterator_for_read(&klass);

    pointer->it->Prev();

    return Qtrue;
  }

  VALUE rocksdb_iterator_close(VALUE klass){
    rocksdb_iterator_pointer* pointer = get_iterator(&klass);

    if(pointer == NULL) {
      return Qfalse;
    }

    if(pointer->it == NULL) {
      return Qfalse;
    }

    delete pointer->it;
    pointer->it = NULL;

    return Qtrue;
  }

  rocksdb_iterator_pointer* get_iterator_for_read(VALUE *klass) {
    rocksdb_iterator_pointer* pointer = get_iterator(klass);

    if (pointer == NULL) {
      VALUE rb_rocksdb_class = rb_const_get(rb_cObject, rb_intern("RocksDB"));
      VALUE rb_rocksdb_error = rb_const_get(rb_rocksdb_class, rb_intern("IteratorClosed"));

      rb_raise(rb_rocksdb_error, "iterator is not initialized");
    }

    if (pointer->db_pointer->db == NULL) {
      VALUE rb_rocksdb_class = rb_const_get(rb_cObject, rb_intern("RocksDB"));
      VALUE rb_rocksdb_error = rb_const_get(rb_rocksdb_class, rb_intern("DatabaseClosed"));

      rb_raise(rb_rocksdb_error, "database is closed");
    }

    if (pointer->it == NULL) {
      VALUE rb_rocksdb_class = rb_const_get(rb_cObject, rb_intern("RocksDB"));
      VALUE rb_rocksdb_error = rb_const_get(rb_rocksdb_class, rb_intern("IteratorClosed"));

      rb_raise(rb_rocksdb_error, "iterator is closed");
    }

    return pointer;
  }

  rocksdb_iterator_pointer* get_iterator(VALUE *klass) {
    rocksdb_iterator_pointer* pointer;
    Data_Get_Struct(*klass, rocksdb_iterator_pointer, pointer);

    return pointer;
  }
}
