# -*- coding: utf-8 -*-
require 'spec_helper'
require "rocksdb"

describe RocksDB do
  before do
    @rocksdb = RocksDB::DB.open temp_db_path
    @rocksdb.put("test", "value")
    @rocksdb.close
  end

  context "when writable" do
    before do
      @rocksdb = RocksDB::DB.open temp_db_path
    end

    it 'writable? is true' do
      expect(@rocksdb.writable?).to eq true
    end

    it 'can write' do
      expect{@rocksdb.put("newtest", "value")}
        .not_to raise_error
    end

    it 'can read' do
      expect(@rocksdb.get("test")).to eq "value"
    end

    after do
      @rocksdb.close
    end
  end

  context "when not writable" do
    before do
      @rocksdb = RocksDB::DB.open_readonly temp_db_path
    end

    it 'writable? is false' do
      expect(@rocksdb.writable?).to eq false
    end

    it "can't write" do
      expect{@rocksdb.put("newtest", "value")}
        .to raise_error(RocksDB::ReadOnly)
    end

    it 'can read' do
      expect(@rocksdb.get("test")).to eq "value"
    end

    after do
      @rocksdb.close
    end
  end
end
