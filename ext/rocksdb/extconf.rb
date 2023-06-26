require "mkmf"

def pkg_config_static(pkg, *opts)
  # Later versions of Ruby, pkg_config take multiple arguments
  # Try the multiple arguments version first
  _opts = opts.dup
  _opts << "static"
  pkg_config(pkg, *_opts)
rescue ArgumentError
  _opts = opts.dup
  switches = _opts[0].dup
  _opts[1..-1].inject(switches) do |result, o|
    result << " --#{o}"
  end
  pkg_config(pkg, "#{switches} --static")
end

# Use rocksdb.pc to get the correct cflags and libraries for rocksdb
# librocksdb is built as a static library, so we need the --static build options
librocksdb_root = File.expand_path('../../librocksdb', __FILE__)
ENV['PKG_CONFIG_PATH'] = File.join(librocksdb_root, 'lib', 'pkgconfig')

# Add libraries for static
# Prepend rocksdb options to avoid using the system rocksdb installation by mistake
rocksdb_cflags = pkg_config_static('rocksdb', 'cflags').to_s
$CFLAGS = rocksdb_cflags + " #{$CFLAGS}"
$CXXFLAGS = rocksdb_cflags + " #{$CXXFLAGS}"
$LDFLAGS = pkg_config_static('rocksdb', 'libs-only-L', 'libs-only-other').to_s + " #{$LDFLAGS}"
$libs = pkg_config_static('rocksdb', 'libs-only-l').to_s + " #{$libs}"

cxx = RbConfig::CONFIG["CXX"]
RbConfig::CONFIG["CPP"] = "#{cxx} -E -std=gnu++17"
RbConfig::CONFIG["CC"] = "#{cxx} -std=gnu++17"

DEBUG_BUILD = have_library('rocksdb_debug') || ENV["DEBUG_LEVEL"]

if have_header('rocksdb/db.h') and (have_library('rocksdb') or have_library('rocksdb_debug'))
  $CPPFLAGS << " -std=gnu++17"

  if DEBUG_BUILD
    CONFIG["optflags"] = "-O0"
  end

  create_makefile("rocksdb/RocksDB")
else
  abort "can't find header or library of rocksdb"
end
