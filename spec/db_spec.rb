
require 'spec_helper'
require "RocksDB"

describe RocksDB do
  it '' do
    
    a = RocksDB.new "/tmp/file2"
    
    
    p "---"
    p a.Put("put1", "aaa") == true
    p "---"
    p a.Get("put1")
    
  end
end
