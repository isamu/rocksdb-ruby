# -*- coding: utf-8 -*-
require 'spec_helper'
require "rocksdb"

describe RocksDB do
  before do
    @rocksdb = RocksDB::DB.new "/tmp/file"
  end

  it 'should get null contained data' do
    @aaa = "aa\0aa"

    @rocksdb.put("test:null", @aaa)
    expect(@rocksdb.get("test:null")).to eq "aa\0aa"
  end

  it 'should get from null contained key' do
    @key = "test:aa\0aa"
    @rocksdb.put(@key, "aaa")
    expect(@rocksdb.get(@key)).to eq "aaa"
    
    @key = "test:aa"
    expect(@rocksdb.get(@key)).to eq nil

  end

  it 'should get multi data' do
    @rocksdb.put("test:nullmulti1\0a", "a\01")
    @rocksdb.put("test:nullmulti2\0a", "b\02")
    @rocksdb.put("test:nullmulti3\0a", "c\03")

    expect(@rocksdb.multi_get(["test:nullmulti1\0a", "test:nullmulti2\0a", "test:nullmulti3\0a"])).to eq ["a\01", "b\02", "c\03"]
    expect(@rocksdb.multi_get(["test:nullmulti1", "test:nullmulti2", "test:nullmulti3"])).to eq ["", "", ""]
  end
  
  after do
    @rocksdb.close
  end
  
end
