#include "rocksdb/db.h"
#include "rocksdb/write_batch.h"

extern "C" {

#include <ruby.h>
  
  typedef VALUE (*METHOD)(...);

  VALUE rocksdb_write_batch_init();
  VALUE batch_alloc(VALUE klass);
  VALUE rocksdb_write_batch_put(VALUE self, VALUE v_key, VALUE v_value);
  VALUE rocksdb_write_batch_delete(VALUE self, VALUE v_key);
}
