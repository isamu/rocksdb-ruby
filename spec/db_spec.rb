require 'spec_helper'
require "RocksDB"

describe RocksDB do
  before do
    @rocksdb = RocksDB::DB.new "/tmp/file"
  end

  it 'should get data' do
    @rocksdb.put("test:read", "1")
    @rocksdb.get("test:read").should eq "1"
  end

  it 'should put data' do 
    @rocksdb.put("test:put", "2").should be_true
    @rocksdb.get("test:put").should eq "2"
  end

  it 'should delete data' do 
    @rocksdb.put("test:delete", "3")
    @rocksdb.get("test:delete").should eq "3"

    @rocksdb.delete("test:delete").should be_true
    @rocksdb.get("test:delete").should be_empty
  end

  it 'should get multi data' do
    @rocksdb.put("test:multi1", "a")
    @rocksdb.put("test:multi2", "b")
    @rocksdb.put("test:multi3", "c")

    @rocksdb.multi_get(["test:multi1", "test:multi2", "test:multi3"]).should eq ["a", "b", "c"]
  end

  after do
    @rocksdb.close
  end

end
