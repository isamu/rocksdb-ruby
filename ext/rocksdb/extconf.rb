require "mkmf"

dir_config('rocksdb')

have_header('db.h')

have_library('rocksdb')

$LDFLAGS= " -lgflags -lz -lbz2"

#$CCFLAGS= " -DROCKSDB_PLATFORM_POSIX  -DOS_MACOSX -DROCKSDB_ATOMIC_PRESENT -DGFLAGS -DZLIB -DBZIP2"
$CPPFLAGS <<  " -std=gnu++11  -DROCKSDB_PLATFORM_POSIX  -DOS_MACOSX -DROCKSDB_ATOMIC_PRESENT -DGFLAGS -DZLIB -DBZIP2 "

#SHARED_CFLAGS=" -fPIC"
#SHARED_EXT=" dylib"
#SHARED_LDFLAGS=" -dynamiclib -install_name "


create_makefile("RocksDB")

