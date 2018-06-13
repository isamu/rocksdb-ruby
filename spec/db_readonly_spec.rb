# -*- coding: utf-8 -*-
require 'spec_helper'
require "rocksdb"

describe RocksDB do
  before do
    @rocksdb = RocksDB::DB.new "/tmp/file2"
    @rocksdb.put("test:multi_db", "1")
    @rocksdb.close

    @rocksdb2 = RocksDB::DB.new "/tmp/file2", {:readonly => true}
  end

  it 'should get data' do
    expect(@rocksdb2.put("test:multi_db", "10")).to eq false
    expect(@rocksdb2.get("test:multi_db")).to eq "1"
  end

  after do
    @rocksdb2.close
  end
end
