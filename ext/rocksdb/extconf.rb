require "mkmf"

dir_config('rocksdb')
RbConfig::CONFIG["CPP"] = "g++ -E -std=gnu++17"

DEBUG_BUILD = have_library('rocksdb_debug') || ENV["DEBUG_LEVEL"]

if have_header('rocksdb/db.h') and (have_library('rocksdb') or have_library('rocksdb_debug'))
  $CPPFLAGS << " -std=gnu++17"

  if DEBUG_BUILD
    CONFIG["optflags"] = "-O0"
  end

  create_makefile("RocksDB/RocksDB")
else
  abort "can't find header or library of rocksdb"
end
