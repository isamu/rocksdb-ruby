#include "rocksdb/db.h"
#include "rocksdb/write_batch.h"

extern "C" {

#include <ruby.h>

  typedef VALUE (*METHOD)(...);
  rocksdb_iterator_pointer* get_iterator(VALUE *klass);
  rocksdb_iterator_pointer* get_iterator_for_read(VALUE *klass);
  void free_iterator(rocksdb_iterator_pointer* pointer);

  VALUE rocksdb_iterator_seek_for_prev(VALUE klass, VALUE v_target);
  VALUE rocksdb_iterator_seek_to_first(VALUE klass);
  VALUE rocksdb_iterator_seek_to_last(VALUE klass);
  VALUE rocksdb_iterator_seek(VALUE klass, VALUE v_target);
  VALUE rocksdb_iterator_alloc(VALUE klass);
  VALUE rocksdb_iterator_valid(VALUE klass);
  VALUE rocksdb_iterator_key(VALUE klass);
  VALUE rocksdb_iterator_value(VALUE klass);
  VALUE rocksdb_iterator_next(VALUE klass);
  VALUE rocksdb_iterator_prev(VALUE klass);
  VALUE rocksdb_iterator_close(VALUE klass);

  VALUE rocksdb_iterator_each(VALUE klass);
  VALUE rocksdb_iterator_reverse_each(VALUE klass);

  VALUE rocksdb_iterator_each_key(VALUE klass);
  VALUE rocksdb_iterator_reverse_each_key(VALUE klass);

  VALUE rocksdb_iterator_each_pair(VALUE klass);
  VALUE rocksdb_iterator_reverse_each_pair(VALUE klass);

  VALUE rocksdb_iterator_each_prefix(VALUE klass, VALUE v_prefix);
  VALUE rocksdb_iterator_each_range(VALUE klass, VALUE v_start, VALUE v_limit);

  void iterate_each(rocksdb::Iterator* it);
  void iterate_each_pair(rocksdb::Iterator* it);
}

