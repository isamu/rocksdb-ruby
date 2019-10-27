#include "rocksdb/db.h"
#include "rocksdb/write_batch.h"

#ifndef RUBY_ROCKSDB_H
#define RUBY_ROCKSDB_H 1

#ifndef NDEBUG
#define TRACE(Out) (std::cerr << __FILE__ << ":" << __LINE__ << " " << Out << std::endl);
#else
#define TRACE(Out)
#endif

extern "C" {
#include <ruby.h>
#define SLICE_TO_RB_STRING(slice) (rb_enc_str_new(slice.data(), slice.size(), rb_utf8_encoding()))
#define SLICE_FROM_RB_VALUE(entity) (rocksdb::Slice((char*)StringValuePtr(entity), RSTRING_LEN(entity)))
#define STRING_FROM_RB_VALUE(entity) (std::string((char*)StringValuePtr(entity), RSTRING_LEN(entity)));

  extern VALUE cRocksdb_iterator;

  typedef VALUE (*METHOD)(...);

  struct rocksdb_pointer{
    rocksdb::DB* db;
    bool readonly;
  };

  struct rocksdb_iterator_pointer{
    rocksdb::Iterator* it;
    rocksdb_pointer* db_pointer;
  };

}
#endif
