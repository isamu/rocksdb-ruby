#include "rocksdb/db.h"
#include "rocksdb/write_batch.h"

extern "C" {
#include <ruby.h>
  VALUE rocksdb_db_init(int argc, VALUE* argv, VALUE self);
  VALUE db_alloc(VALUE klass);
  VALUE rocksdb_db_put(VALUE self, VALUE v_key, VALUE v_value);
  VALUE rocksdb_db_write(VALUE self, VALUE v_write);
  VALUE rocksdb_db_get(VALUE self, VALUE v_key);
  VALUE rocksdb_db_multi_get(VALUE self, VALUE v_array);
  VALUE rocksdb_db_delete(VALUE self, VALUE v_key);
  VALUE rocksdb_db_close(VALUE self);
  VALUE rocksdb_db_debug(VALUE self);
  VALUE rocksdb_db_new_iterator(VALUE self);
  VALUE rocksdb_db_each(VALUE self);

}
