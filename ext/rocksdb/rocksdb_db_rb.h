#include "rocksdb/db.h"
#include "rocksdb/write_batch.h"
#include "rocksdb/utilities/convenience.h"

extern "C" {
#include <ruby.h>
  VALUE rocksdb_db_init(VALUE self, VALUE v_db_path, VALUE v_readonly, VALUE v_db_options);
  VALUE db_alloc(VALUE klass);

  VALUE rocksdb_db_close(VALUE self);
  VALUE rocksdb_db_put(VALUE self, VALUE v_key, VALUE v_value);
  VALUE rocksdb_db_write(VALUE self, VALUE v_write);
  VALUE rocksdb_db_property(VALUE self, VALUE v_key);
  VALUE rocksdb_db_options(VALUE self);
  VALUE rocksdb_db_get(VALUE self, VALUE v_key);
  VALUE rocksdb_db_multi_get(VALUE self, VALUE v_array);
  VALUE rocksdb_db_delete(VALUE self, VALUE v_key);
  VALUE rocksdb_db_exists(VALUE self, VALUE v_key);

  VALUE rocksdb_db_debug(VALUE self);
  VALUE rocksdb_db_is_writable(VALUE self);
  VALUE rocksdb_db_is_open(VALUE self);
  VALUE rocksdb_db_to_iterator(VALUE self);
  VALUE rocksdb_db_each(VALUE self);
  VALUE rocksdb_db_reverse_each(VALUE self);
  VALUE rocksdb_db_each_key(VALUE self);
  VALUE rocksdb_db_each_pair(VALUE self);
  VALUE rocksdb_db_each_prefix(VALUE self, VALUE v_prefix);
  VALUE rocksdb_db_each_range(VALUE self, VALUE v_start, VALUE v_limit);
  VALUE rocksdb_db_compact(int argc, VALUE* argv, VALUE self);

  VALUE raise_status_error(rocksdb::Status *status);
  void db_free(rocksdb_pointer* db_pointer);

  rocksdb_pointer* get_db(VALUE *self);
  rocksdb_pointer* get_db_for_read(VALUE *self);
  rocksdb_pointer* get_db_for_write(VALUE *self);
  void check_is_db_ready(rocksdb_pointer *db_pointer);
}
