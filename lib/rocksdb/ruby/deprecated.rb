# Deprecated methods, kept for backward compatibility
module RocksDB
  class DBError < ::RocksDB::Error;

  class Iterator
    extend Gem::Deprecate

    alias_method :valid, :valid?
    deprecate :valid, :valid?, 2019, 12
  end

  class DB
    extend Gem::Deprecate

    alias_method :new_iterator, :to_iterator
    deprecate :new_iterator, :to_iterator, 2019, 12

    def is_readonly?
      !writable?
    end
    deprecate :is_readonly?, :writable?, 2019, 12

    alias_method :is_open?, :open?
    deprecate :is_open?, :open?, 2019, 12

    alias_method :multi_get, :get_many
    deprecate :multi_get, :get_many, 2019, 12
  end
end
