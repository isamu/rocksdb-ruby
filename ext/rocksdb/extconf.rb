require "mkmf"

dir_config('rocksdb')
RbConfig::CONFIG["CPP"] = "g++ -E -std=gnu++11"

if have_header('rocksdb/db.h') and have_library('rocksdb') 
  $CPPFLAGS << " -std=gnu++11"
  create_makefile("RocksDB/RocksDB")
else
  abort "can't find header or library of rocksdb"
end
