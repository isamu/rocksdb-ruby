# -*- coding: utf-8 -*-
require 'spec_helper'
require "rocksdb"

describe RocksDB do
  before do
    @rocksdb = RocksDB::DB.new "/tmp/file2", {:readonly => true}
  end

  it 'should get data' do
    @rocksdb.put("test:multi_db", "10")
    expect(@rocksdb.get("test:multi_db")).to eq "2"
  end

  after do
    @rocksdb.close
  end
end
