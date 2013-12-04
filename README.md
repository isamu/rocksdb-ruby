# RocksDB

The rocksdb is a persistent in-process key-value store.

Read more about it here: http://rocksdb.org/

This gem contains Ruby bindings so that you can use it from your Ruby process.

## Installation

First install rocksdb.

Add this line to your application's Gemfile:

    gem 'rocksdb-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rocksdb-ruby

## Usage

    require "rocksdb"

    # Reads And Writes
    key = "test"
    value = "1"
    rocksdb = RocksDB::DB.new "/tmp/file"
    rocksdb.put(key, value)
    new_value = rocksdb.get(key)
    rocksdb.delete(key)

    #Atomic Updates
    batch = RocksDB::Batch.new
    batch.delete("test:batch1")
    batch.put("test:batch2", "b")
    rocksdb.write(batch)

    #Iteration
    iterator = rocksdb.new_iterator

    iterator.seek_to_first
    while(iterator.valid)
      iterator.value
      iterator.key
      iterator.next
    end
    iterator.close

    
    rocksdb.close


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
