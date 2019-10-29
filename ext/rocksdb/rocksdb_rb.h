#include "rocksdb/db.h"
#include "rocksdb/write_batch.h"
#include "rocksdb/version.h"

#ifndef RUBY_ROCKSDB_H
#define RUBY_ROCKSDB_H 1

#ifndef NDEBUG
#include <iostream>
#define TRACE(Out) (std::cerr << __FILE__ << ":" << __LINE__ << "(" << __func__ << ") " << Out << std::endl);
#else
#define TRACE(Out)
#endif

#define ROCKSDB_VERSION (ROCKSDB_MAJOR * 10000 \
                       + ROCKSDB_MINOR * 100 \
                       + ROCKSDB_PATCH)

extern "C" {
#include <ruby.h>

#define SLICE_TO_RB_STRING(slice) (rb_enc_str_new(slice.data(), slice.size(), rb_utf8_encoding()))
#define SLICE_FROM_RB_VALUE(entity) ({ VALUE _string = StringValue((entity)); rocksdb::Slice(RSTRING_PTR(_string), RSTRING_LEN(_string)); })
#define STRING_FROM_RB_VALUE(entity) ({ VALUE _string = StringValue(entity); std::string(RSTRING_PTR(_string), RSTRING_LEN(_string)); })

  extern VALUE cRocksdb;
  extern VALUE cRocksdb_iterator;

  extern VALUE cRocksdb_database_closed;
  extern VALUE cRocksdb_iterator_closed;
  extern VALUE cRocksdb_status_error;
  extern VALUE cRocksdb_readonly;

  typedef VALUE (*METHOD)(...);

  struct rocksdb_pointer{
    rocksdb::DB* db;
    bool readonly;
  };

  struct rocksdb_iterator_pointer{
    rocksdb::Iterator* it;
    rocksdb_pointer* db_pointer;
  };

  VALUE rocksdb_version(VALUE self);
}
#endif
