# -*- coding: utf-8 -*-
require 'spec_helper'
require "RocksDB"

describe RocksDB::Iterator do
  before do
    @rocksdb = RocksDB::DB.open temp_db_path

    @rocksdb.put("test:00001", "1")
    @rocksdb.put("test:00002", "2")
    @rocksdb.put("test:00003", "3")
    @rocksdb.put("test:00004", "4")
    @rocksdb.put("test:00005", "5")

    @iterator = @rocksdb.new_iterator
  end

  context "valid" do
    it 'should be valid at start' do
      @iterator.seek_to_first
      expect(@iterator).to be_valid
    end

    it 'should not be valid at end' do
      @iterator.seek_to_last
      @iterator.next
      expect(@iterator).to_not be_valid
    end

    it 'should not be valid when closed' do
      @iterator.close

      expect(@iterator).to_not be_valid
    end

    it 'should not be valid when database closed' do
      @rocksdb.close
      expect(@iterator).to_not be_valid
    end
  end

  context 'close' do
    it 'closes iterator' do
      @iterator.close
      expect(@iterator).to_not be_valid
    end

    it 'raises exception on closed iterator' do
      @iterator.close
      expect{@iterator.seek_to_first}.to raise_error(RocksDB::IteratorClosed)
    end

    it 'raises exception on closed database' do
      @rocksdb.close
      expect{@iterator.seek_to_first}.to raise_error(RocksDB::DatabaseClosed)
    end
  end

  it 'should seek to first' do
    @iterator.seek_to_first

    expect(@iterator.key).to eq "test:00001"
    expect(@iterator.value).to eq "1"
  end

  it 'should seek to last' do
    @iterator.seek_to_last

    expect(@iterator.key).to eq "test:00005"
    expect(@iterator.value).to eq "5"
  end

  it 'should seek to position' do
    @iterator.seek "test:00003"

    expect(@iterator.key).to eq "test:00003"
    expect(@iterator.value).to eq "3"
  end

  it 'should seek to previous' do
    @iterator.seek_to_previous "test:00004"

    expect(@iterator.key).to eq "test:00004"
    expect(@iterator.value).to eq "4"
  end

  it 'should go forward' do
    @iterator.seek_to_first
    @iterator.next

    expect(@iterator.key).to eq "test:00002"
    expect(@iterator.value).to eq "2"
  end

  it 'should go back' do
    @iterator.seek_to_last
    @iterator.previous

    expect(@iterator.key).to eq "test:00004"
    expect(@iterator.value).to eq "4"
  end

  it 'should iterate all the way to the end' do
    result = {}
    @iterator.seek_to_first

    while @iterator.valid?
      result[@iterator.key] = @iterator.value
      @iterator.next
    end

    expect(result).to eq ({
      "test:00001" => "1",
      "test:00002" => "2",
      "test:00003" => "3",
      "test:00004" => "4",
      "test:00005" => "5"
    })
  end

  after do
    @rocksdb.close
  end
end
