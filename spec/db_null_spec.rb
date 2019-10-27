# -*- coding: utf-8 -*-
require 'spec_helper'
require "rocksdb"

describe RocksDB do
  context "null-terminated strings" do
    before do
      @rocksdb = RocksDB.open temp_db_path

      @rocksdb.put("test:text1\0a", "hello")
      @rocksdb.put("test:plain", "he\0llo")
      @rocksdb.put("test:null\0a", "he\0llo")
      @rocksdb.put("test:nullmulti1\0a", "a\0a1")
      @rocksdb.put("test:nullmulti2\0a", "b\0a2")
      @rocksdb.put("test:nullmulti3\0a", "c\0a3")
    end

    it 'should get key with null bytes' do
      expect(@rocksdb.get("test:text1\0a")).to eq "hello"
    end

    it 'should get value with null bytes' do
      expect(@rocksdb.get("test:plain")).to eq "he\0llo"
    end

    it 'should get key and value with null bytes' do
      expect(@rocksdb.get("test:null\0a")).to eq "he\0llo"
    end

    it 'should get all pairs' do
      expect(@rocksdb.get("test:nullmulti1\0a", "test:nullmulti2\0a", "test:nullmulti3\0a")).to eq ["a\0a1", "b\0a2", "c\0a3"]

      expect(@rocksdb.get("test:nullmulti1", "test:nullmulti2", "test:nullmulti3")).to eq [nil, nil, nil]
    end

    after do
      @rocksdb.close
    end
  end
end
