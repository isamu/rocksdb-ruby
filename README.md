[![Build Status](https://app.travis-ci.com/isamu/rocksdb-ruby.svg?branch=master)](https://app.travis-ci.com/github/isamu/rocksdb-ruby)
[![Gem Version](https://badge.fury.io/rb/rocksdb-ruby.svg)](https://badge.fury.io/rb/rocksdb-ruby)

# RocksDB

The rocksdb is a persistent in-process key-value store.

Read more about it here: http://rocksdb.org/

This gem contains Ruby bindings so that you can use it from your Ruby process.

## Installation

First, install rocksdb: https://github.com/facebook/rocksdb/blob/master/INSTALL.md

Add this line to your application's Gemfile:

```ruby
gem 'rocksdb-ruby'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install rocksdb-ruby
```

`rocksdb-ruby` is tested against Ruby 2.4, 2.5 and 2.6 on Linux and macOS platforms. However, it might work on other platforms.

`rocksdb-ruby` supports rocksb 4.5.1 and later. It is tested against master branch with all supported ruby version. It is also tested against few specific version, available in popular distributions. Check `.travis.yml` for details.

JRuby, TruffleRuby and Rubinius are not supported at the moment.

## Usage


### Open database

First, you need to open database. Use `open` method and pass path to database
root as first argument. By default, it will create path if missing.

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file1"
```

You can pass RocksDB options as second argument:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file2", compression: "kNoCompression"
```

Or you can pass raw Option String:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file2", "compression=kNoCompression"
```

Read more about Option Sting: https://github.com/facebook/rocksdb/wiki/Option-String-and-Option-Map#option-string

### Basic reads and writes

You can read and write keys using `put` and `get` methods:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file3"

    # Store string `World` under key `Hello`
    rocksdb.put "Hello", "World"

    # Read a value stored under key `Hello`
    puts rocksdb.get "Hello"
    # => World
```

You can also use Hash-like methods `[]` and `[]=`

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file4"

    # Store string `World` under key `Hello`
    rocksdb["Hello"] = "World"

    # Read a value stored under key `Hello`
    puts rocksdb["Hello"]
    # => World
```

If key does not exists, RocksDB will return nil:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file5"

    # Try to read a key, that does not exists
    result = rocksdb.get "Missing Key"

    if !result
      puts "Key not found!"
    end

    # => Key not found
```

If you want to get multiple keys at the same time, you can use `get` with multiple arguments:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file6"

    rocksdb.put "First Key", "First Value"
    rocksdb.put "Second Key", "Second Value"
    rocksdb.put "Third Key", "Third Value"

    # If key does not exists, you'll get nil
    values = rocksdb.get "Second Key", "Imaginary Key", "Third Key"

    puts values
    # => ["Second Value", nil, "Third Value"]
```

You can check, if key exists:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file7"

    rocksdb.put "Real Key", "Real Value"

    rocksdb.exists? "Real Key"
    # => true

    rocksdb.exists? "Imaginary Key"
    # => false
```

`exists?` method returns result of KeyMayExist. 

If you need more infomation about KeyMayExist,  see [rockdb source comments](https://github.com/facebook/rocksdb/blob/689b13e6396011317db4f04a88e72323aead32bd/include/rocksdb/db.h#L646-L662).

And you can delete keys, when not needed:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file8"

    rocksdb.put "Delete Me", "Memory"
    rocksdb.exists? "Delete Me"
    # => true
    rocksdb.delete "Delete Me"
    rocksdb.exists? "Delete Me"
    # => false

    rocksdb.get "Delete Me"
    # => nil
```

You can open RocksDB only for reading:

```ruby

    require "rocksdb"

    # Open only for reading
    rocksdb = RocksDB.open_readonly "/tmp/file9"

    puts rocksdb.writable?
    # => false

    rocksdb.put "First Key", "First Value"

    # => RocksDB::ReadOnly (database is read-only)
```


### Enumerable

You can enumerate over all values using `each` method. Note how values are sorted lexicographically by their keys:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file10"

    rocksdb.put "One", "1"
    rocksdb.put "Two", "2"
    rocksdb.put "Three", "3"

    rocksdb.each do |value|
      puts value
    end

    # => 1
    # => 3
    # => 2
```

Additionally, you can enumerate in reverse order with `reverse_each`:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file11"

    rocksdb.put "One", "1"
    rocksdb.put "Two", "2"
    rocksdb.put "Three", "3"

    rocksdb.reverse_each do |value|
      puts value
    end

    # => 2
    # => 3
    # => 1
```

You can enumerate over keys with `each_key` or in reverse order with `reverse_each_key`:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file12"

    rocksdb.put "One", "1"
    rocksdb.put "Two", "2"
    rocksdb.put "Three", "3"

    rocksdb.each_key do |key|
      puts key
    end

    # => One
    # => Three
    # => Two

    rocksdb.reverse_each_key do |key|
      puts key
    end

    # => Two
    # => Three
    # => One
```

You can enumerate over both keys and values with `each_pair` and in reverse order with `reverse_each_pair`:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file13"

    rocksdb.put "One", "1"
    rocksdb.put "Two", "2"
    rocksdb.put "Three", "3"

    rocksdb.each_pair do |key, value|
      puts "#{key} = #{value}"
    end

    # => One = 1
    # => Three = 3
    # => Two = 2
```

Additionally, you can enumerate over keys that start with a specific prefix with `each_prefix`:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file14"

    rocksdb.put "my:1", "1"
    rocksdb.put "my:2", "2"
    rocksdb.put "your:3", "3"

    rocksdb.each_prefix("my") do |key, value|
      puts "#{key} = #{value}"
    end

    # => my:1 = 1
    # => my:2 = 2
```

Or you can scan over the ranges of keys with `each_range`. Note, range is `[start, limit]`:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file15"

    10.times do |count|
      rocksdb.put "key:#{count}", "#{count}"
    end

    rocksdb.each_range("key:5", "key:7") do |key, value|
      puts "#{key} = #{value}"
    end

    # => key:5 = 5
    # => key:6 = 6
    # => key:7 = 7
```

### Atomic Batches

You can use `RocksDB::Batch` to atomically insert big chunks of data.

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file16"

    batch = RocksDB::Batch.new

    batch.delete("test:batch1")
    batch.put("test:batch2", "b")

    rocksdb.write(batch)

    rocksdb.each_pair do |key, value|
      puts "#{key} = #{value}"
    end

    # => test:batch2 = b
```

Read more about RocksDB batches: https://github.com/facebook/rocksdb/wiki/Basic-Operations#atomic-updates

# Iterator

You can get RocksDB Iterator with `to_iterator` method to iterate over your data:

```ruby

    require "rocksdb"

    # Open for reads and writes
    rocksdb = RocksDB.open "/tmp/file16"

    10.times do |count|
      rocksdb.put "key:#{count}", "#{count}"
    end

    # Get Iterator
    iterator = rocksdb.to_iterator
    # Seek to some position. You can also use seek("key") to
    iterator.seek_to_first

    while iterator.valid?
      puts "#{iterator.value} = #{iterator.key}"
      iterator.next
    end

    iterator.close
```

Supported methods:

* `seek(key)` seeks to closest key to given prefix at beginning
* `seek_to_first` seeks to the first key
* `seek_to_last` seeks to the last key
* `next` seeks to the next key
* `previous` seeks to the previous key
* `valid?` returns true if iterator can be iterated
* `close` closes iterator
* `key` returns current key
* `value` returns current value

Methods supported by rocksdb 4.11 and later:

* `seek_for_previous(key)`seeks to closest key to given prefix at end

## Upgrade

When upgrading from `0.2` version, please note the following breaking changes:

* `multi_get` will return `nil` instead of empty string
* `RocksDB::DB.get_instance` is removed. Implement your own DB instance cache if needed
* `each_` methods now returns `Enumerator` instead of `RocksDB::Iterator`

Also, there some things that are now deprecated and will be removed in future versions:

* `RocksDB::DBError` was deprecated and replaced with `RocksDB::Error`. Specific errors now have their own exception class: `ReadOnly`, `DatabaseClosed`, `IteratorClosed`, `StatusError`
* `is_open?` was replaced with `open?`
* `is_readonly?` was replaced with `writable?`
* `multi_get` was replaced with `get_many`
* `new_iterator` was replaced with `to_iterator`
* `Iterator#valid` was replaced with `Iterator#valid?`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
