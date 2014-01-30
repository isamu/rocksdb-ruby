# -*- coding: utf-8 -*-
require 'spec_helper'
require "rocksdb"

describe RocksDB do
  before do
    @rocksdb = RocksDB::DB.new "/tmp/file3", {:max_bytes_for_level_base => 10485760, :max_grandparent_overlap_factor => 20}
  end

  it 'should get data' do
    @rocksdb.put("test:multi_db", "10")
    expect(@rocksdb.get("test:multi_db")).to eq "10"
  end

  after do
    @rocksdb.close
  end
end
