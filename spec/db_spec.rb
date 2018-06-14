# -*- coding: utf-8 -*-
require 'spec_helper'
require "rocksdb"

describe RocksDB do
  before do
    @rocksdb = RocksDB::DB.new("/tmp/file")
  end

  it 'should get data' do
    @rocksdb.put("test:read", "1")
    expect(@rocksdb.is_readonly?).to eq false
    expect(@rocksdb.get("test:read")).to eq "1"
  end

  it 'should put data' do 
    expect(@rocksdb.put("test:put", "2")).to be true
    expect(@rocksdb.get("test:put")).to eq "2"
  end

  it 'should delete data' do 
    @rocksdb.put("test:delete", "3")
    expect(@rocksdb.get("test:delete")).to eq "3"

    expect(@rocksdb.delete("test:delete")).to be true
    expect(@rocksdb.get("test:delete")).to be_nil
  end

  it 'should get multi data' do
    @rocksdb.put("test:multi1", "a")
    @rocksdb.put("test:multi2", "b")
    @rocksdb.put("test:multi3", "c")

    expect(@rocksdb.multi_get(["test:multi1", "test:multi2", "test:multi3"])).to eq ["a", "b", "c"]
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

  it 'should use multiple db' do
    @rocksdb2 = RocksDB::DB.new("/tmp/file2")
    @rocksdb.put("test:multi_db", "1")
    @rocksdb2.put("test:multi_db", "2")
    
    expect(@rocksdb.get("test:multi_db")).to eq "1"
    expect(@rocksdb2.get("test:multi_db")).to eq "2"
    @rocksdb2.close
  end

  it 'should use japanese charactor' do
    @rocksdb.put("test:japanese", "あいうえお")

    expect(@rocksdb.get("test:japanese")).to eq "あいうえお"
    expect(@rocksdb.multi_get(["test:japanese"])).to eq ["あいうえお"]
  end

  it 'should use each' do
    iter = @rocksdb.each 

    array = []
    @rocksdb.each do |value|
      expect(value).not_to be_empty
      array << value
    end

    rev_array = []
    @rocksdb.reverse_each do |value|
      expect(value).not_to be_empty
      rev_array << value
    end
 

    expect(array).to eq rev_array.reverse

    @rocksdb.each_index do |key|
      expect(key).not_to be_empty
    end

    @rocksdb.each_with_index do |key, value|
      expect(key).not_to be_empty
      expect(value).not_to be_empty
    end

    iter.close
  end

  it 'should exists?' do
    @rocksdb.put("test:exists?", "a")
    @rocksdb.delete("test:noexists?")
    expect(@rocksdb.exists?("test:exists?")).to be true
    expect(@rocksdb.exists?("test:noexists?")).to be false

    expect(@rocksdb.includes?("test:exists?")).to be true
    expect(@rocksdb.includes?("test:noexists?")).to be false

  end

  it 'hash' do
    @rocksdb.delete("test:hash")
    expect(@rocksdb["test:hash"]).to be_nil
    @rocksdb["test:hash"] = "a"
    expect(@rocksdb["test:hash"]).to eq "a"

  end

  it 'race condition test' do
    key = "test"
    value = "1"

    expect{RocksDB::DB.new("/tmp/file")}.to raise_error(RocksDB::DBError)

    expect(@rocksdb.put("test:put", "1")).to be true

    @rocksdb2 = RocksDB::DB.new("/tmp/file", {:readonly => true})
    expect(@rocksdb2.is_readonly?).to eq true
    expect(@rocksdb2.get("test:put")).to eq "1"

    @rocksdb.close

    expect(@rocksdb.is_open?).to eq false

    @rocksdb = RocksDB::DB.new("/tmp/file")
    expect(@rocksdb.is_readonly?).to eq false
    expect(@rocksdb.is_open?).to eq true
    expect(@rocksdb.put("test:put", "2")).to be true
    
    @rocksdb3 = RocksDB::DB.new("/tmp/file", {:readonly => true})
    expect(@rocksdb3.is_readonly?).to eq true
    expect(@rocksdb3.is_open?).to eq true
    expect(@rocksdb3.get("test:put")).to eq "2"

    @rocksdb2.close
    @rocksdb3.close
    
  end
  
  it 'singleton' do
    @rocksdb2 = RocksDB::DB.get_instance("/tmp/file")
    expect(@rocksdb2.is_readonly?).to eq false
    expect(@rocksdb2.is_open?).to eq true

    @rocksdb3 = RocksDB::DB.get_instance("/tmp/file")
    expect(@rocksdb3.is_readonly?).to eq false
    expect(@rocksdb).to eq (@rocksdb3)
    expect(@rocksdb2).to eq (@rocksdb3)
    
    @rocksdb4 = RocksDB::DB.get_instance("/tmp/file", {:readonly => true})
    expect(@rocksdb2).not_to eq (@rocksdb4)
    expect(@rocksdb4.is_readonly?).to eq true
    expect(@rocksdb4.is_open?).to eq true
    
    @rocksdb2.close
    expect{@rocksdb2.get("test:put")}.to raise_error(RuntimeError)
    expect(@rocksdb2.is_open?).to eq false
    expect{@rocksdb3.get("test:put")}.to raise_error(RuntimeError)
    expect(@rocksdb3.is_open?).to eq false

    @rocksdb4.close
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

