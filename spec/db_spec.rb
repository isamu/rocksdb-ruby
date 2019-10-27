# -*- coding: utf-8 -*-
require 'spec_helper'
require "rocksdb"
require 'fileutils'

describe RocksDB do
  before do
    @rocksdb = RocksDB::DB.open(temp_db_path)
  end

  context "close" do
    it 'closes database' do
      @rocksdb.close
      expect(@rocksdb.open?).to eq false
    end

    it 'not fails to close database that is already closes' do
      @rocksdb.close
      @rocksdb.close
      expect(@rocksdb.open?).to eq false
    end

    it 'raises exception on closed database' do
      @rocksdb.close

      expect{ @rocksdb.get "test" }
        .to raise_error(RocksDB::DatabaseClosed)
      expect{ @rocksdb.put "test", "value" }
        .to raise_error(RocksDB::DatabaseClosed)
    end
  end

  context "get_one" do
    it 'should get data' do
      @rocksdb.put("test:read", "1")
      expect(@rocksdb.get_one("test:read")).to eq "1"
    end

    it 'should get with []' do
      @rocksdb.delete("test:hash")
      expect(@rocksdb["test:hash"]).to be_nil
      @rocksdb.put("test:hash", "42")
      expect(@rocksdb["test:hash"]).to eq "42"
    end

    it 'should return nil if not found' do
      expect(@rocksdb.get_one("must_not_be_found")).to be_nil
    end
  end

  context "get_many" do
    before do
      @rocksdb.put("test:multi1", "a")
      @rocksdb.put("test:multi2", "b")
      @rocksdb.put("test:multi3", "c")
    end

    it 'should get all values' do
      expect(@rocksdb.get_many(["test:multi1", "test:multi2", "test:multi3"]))
            .to eq ["a", "b", "c"]
    end

    it 'should return nil if key not found' do
      @rocksdb.delete("test:multi2")

      expect(@rocksdb.get_many(["test:multi1", "test:multi2", "test:multi3"]))
            .to eq ["a", nil, "c"]
    end
  end

  context "get" do
    before do
      @rocksdb.put("test:multi1", "a")
      @rocksdb.put("test:multi2", "b")
      @rocksdb.put("test:multi3", "c")
    end

    it 'should get one, when one argument' do
      expect(@rocksdb.get("test:multi2"))
            .to eq "b"
    end

    it 'should get many, when two or more arguments' do
      expect(@rocksdb.get("test:multi1", "test:multi2", "test:multi3"))
            .to eq ["a", "b", "c"]
    end

    it 'should get many, when array given' do
      expect(@rocksdb.get(["test:multi1", "test:multi2", "test:multi3"]))
            .to eq ["a", "b", "c"]
    end
  end

  context "put" do
    it 'should put data' do
      expect(@rocksdb.put("test:put", "2")).to be true
      expect(@rocksdb.get("test:put")).to eq "2"
    end

    it 'should overwrite data with put' do
      expect(@rocksdb.put("test:put", "2")).to be true
      expect(@rocksdb.get("test:put")).to eq "2"

      expect(@rocksdb.put("test:put", "3")).to be true
      expect(@rocksdb.get("test:put")).to eq "3"
    end

    it 'should put any data that can behave like string' do
      class CastableTest
        def initialize(value)
          @value = value
        end

        def to_str
          @value.to_s
        end
      end

      castable_key = CastableTest.new(42)
      castable_value = CastableTest.new([1984])

      expect(@rocksdb.put(castable_key, castable_value)).to be true
      expect(@rocksdb.get("42")).to eq "[1984]"
    end

    it "should gracefully fail on non-string objects" do
      expect{ @rocksdb.put(42, true) }.to raise_error(TypeError)
    end

    it 'should put data atomic update' do
      @rocksdb.put("test:batch1", "a")
      @rocksdb.delete("test:batch2")

      expect(@rocksdb.get("test:batch1")).to eq "a"
      expect(@rocksdb.get("test:batch")).to be_nil

      batch = RocksDB::Batch.new
      batch.delete("test:batch1")
      batch.put("test:batch2", "b")
      @rocksdb.write(batch)

      expect(@rocksdb.get("test:batch1")).to be_nil
      expect(@rocksdb.get("test:batch2")).to eq "b"
    end

    it 'should put and read multibyte data' do
      @rocksdb.put("test:japanese", "あいうえお")
      @rocksdb.put("test:russian", "Перепёлка")

      expect(@rocksdb.get("test:japanese")).to eq "あいうえお"
      expect(@rocksdb.get("test:japanese", "test:russian"))
        .to eq ["あいうえお", "Перепёлка"]
    end

    it 'should put with []=' do
      @rocksdb.delete("test:hash")
      expect(@rocksdb["test:hash"]).to be_nil
      @rocksdb["test:hash"] = "a"
      expect(@rocksdb.get("test:hash")).to eq "a"
    end
  end

  context "exists?" do
    it 'returns true when exists' do
      @rocksdb.put "test:exists?", "a"

      expect(@rocksdb.exists?("test:exists?")).to be true
      expect(@rocksdb.includes?("test:exists?")).to be true
    end

    it 'returns false when no exists' do
      expect(@rocksdb.exists?("test:noexists?")).to be false
      expect(@rocksdb.includes?("test:noexists?")).to be false
    end

    it 'returns false when key deleted' do
      @rocksdb.put "test:deleted_key", "deleted_value"
      @rocksdb.delete "test:deleted_key"

      expect(@rocksdb.exists?("test:deleted_key")).to be false
      expect(@rocksdb.includes?("test:deleted_key")).to be false
    end
  end

  context "delete" do
    it 'should delete data' do
      @rocksdb.put("test:delete", "3")
      expect(@rocksdb.get("test:delete")).to eq "3"

      expect(@rocksdb.delete("test:delete")).to be true
      expect(@rocksdb.get("test:delete")).to be_nil
    end

    it 'should return true even if key does not exists' do
      @rocksdb.delete("must_not_be_found_to_delete")
      expect(@rocksdb.delete("must_not_be_found_to_delete")).to be true
    end
  end

  it "should get property" do
    @rocksdb.put("test:read", "1")
    expect(@rocksdb.property("rocksdb.estimate-num-keys")).to eq("1")
  end


  it 'should use multiple db' do
    @rocksdb2 = RocksDB::DB.new("/tmp/file2")
    @rocksdb.put("test:multi_db", "1")
    @rocksdb2.put("test:multi_db", "2")

    expect(@rocksdb.get("test:multi_db")).to eq "1"
    expect(@rocksdb2.get("test:multi_db")).to eq "2"
    @rocksdb2.close
  end

  it 'race condition test' do
    key = "test"
    value = "1"

    expect{RocksDB::DB.open(temp_db_path)}.to raise_error(RocksDB::Error)

    expect(@rocksdb.put("test:put", "1")).to be true

    @rocksdb2 = RocksDB::DB.open_readonly(temp_db_path)
    expect(@rocksdb2.writable?).to eq false
    expect(@rocksdb2.get("test:put")).to eq "1"

    @rocksdb.close

    expect(@rocksdb.open?).to eq false

    @rocksdb = RocksDB::DB.open(temp_db_path)
    expect(@rocksdb.writable?).to eq true
    expect(@rocksdb.open?).to eq true
    expect(@rocksdb.put("test:put", "2")).to be true

    @rocksdb3 = RocksDB::DB.open_readonly(temp_db_path)
    expect(@rocksdb3.writable?).to eq false
    expect(@rocksdb3.open?).to eq true
    expect(@rocksdb3.get("test:put")).to eq "2"

    @rocksdb2.close
    @rocksdb3.close
  end

  context 'compact' do
    it 'works with no parameters' do
      expect(@rocksdb.compact).to eq(true)
    end

    it 'works with one parameter' do
      expect(@rocksdb.compact('a')).to eq(true)
    end

    it 'works with two parameters' do
      expect(@rocksdb.compact('a', 'x')).to eq(true)
    end

    it 'works with nil as first parameter' do
      expect(@rocksdb.compact(nil, 'x')).to eq(true)
    end
  end

  after do
    @rocksdb.close
  end
end
