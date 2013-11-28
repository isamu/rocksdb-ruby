# -*- coding: utf-8 -*-
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

  it 'should put data atomic update' do
    @rocksdb.put("test:batch1", "a")
    @rocksdb.delete("test:batch2")

    @rocksdb.get("test:batch1").should eq "a"
    @rocksdb.get("test:batch").should eq ""

    batch = RocksDB::Batch.new
    batch.delete("test:batch1")
    batch.put("test:batch2", "b")
    @rocksdb.write(batch)

    @rocksdb.get("test:batch1").should eq ""
    @rocksdb.get("test:batch2").should eq "b"
  end

  it 'should use multiple db' do
    @rocksdb2 = RocksDB::DB.new "/tmp/file2"
    
    @rocksdb.put("test:multi_db", "1")
    @rocksdb2.put("test:multi_db", "2")
    
    @rocksdb.get("test:multi_db").should eq "1"
    @rocksdb2.get("test:multi_db").should eq "2"
  end

  it 'should use japanese charactor' do
    @rocksdb.put("test:japanese", "あいうえお")
    @rocksdb.get("test:japanese").should eq "あいうえお"
  end


  after do
    @rocksdb.close
  end

  #rocksdb::WriteOptions write_options;
  #write_options.sync = true;

end

