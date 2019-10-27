# -*- coding: utf-8 -*-
require 'spec_helper'
require "RocksDB"

describe RocksDB::Iterator do
  before do
    @rocksdb = RocksDB::DB.open temp_db_path

    @rocksdb.put("test1:0001", "a")
    @rocksdb.put("test1:0002", "b")
    @rocksdb.put("test1:0003", "c")
    @rocksdb.put("test1:0004", "d")
    @rocksdb.put("test1:0005", "e")

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

  context "enumerable" do
    context "each" do
      it 'iterates over all values' do
        values = []

        @rocksdb.each do |value|
          values << value
        end

        expect(values).to eq ["a", "b", "c", "d", "e"]
      end

      it 'returns enumerable' do
        expect(@rocksdb.each)
          .to be_a(Enumerable)
      end
    end

    context "reverse_each" do
      it 'iterates over all values in reverse order' do
        values = []

        @rocksdb.reverse_each do |value|
          values << value
        end

        expect(values).to eq ["e", "d", "c", "b", "a"]
      end

      it 'returns enumerable' do
        expect(@rocksdb.reverse_each)
          .to be_a(Enumerable)
      end
    end

    context "each_key" do
      it 'iterates over all keys' do
        keys = []

        @rocksdb.each_key do |key|
          keys << key
        end

        expect(keys).to eq [
          "test1:0001",
          "test1:0002",
          "test1:0003",
          "test1:0004",
          "test1:0005"
        ]
      end

      it 'returns enumerable' do
        expect(@rocksdb.each_key)
          .to be_a(Enumerable)
      end
    end

    context "reverse_each_key" do
      it 'iterates over all keys in reverse order' do
        keys = []

        @rocksdb.reverse_each_key do |key|
          keys << key
        end

        expect(keys).to eq [
          "test1:0005",
          "test1:0004",
          "test1:0003",
          "test1:0002",
          "test1:0001"
        ]
      end

      it 'returns enumerable' do
        expect(@rocksdb.reverse_each_key)
          .to be_a(Enumerable)
      end
    end

    context "each_pair" do
      it 'iterates over all values and keys' do
        pairs = {}

        @rocksdb.each_pair do |key, value|
          pairs[key] = value
        end

        expect(pairs).to eq ({
          "test1:0001"=>"a",
          "test1:0002"=>"b",
          "test1:0003"=>"c",
          "test1:0004"=>"d",
          "test1:0005"=>"e"
        })
      end

      it 'returns enumerable' do
        expect(@rocksdb.each_pair)
          .to be_a(Enumerable)
      end
    end

    context "reverse_each_pair" do
      it 'iterates over all values and keys in reverse order' do
        pairs = {}

        @rocksdb.reverse_each_pair do |key, value|
          pairs[key] = value
        end

        expect(pairs).to eq ({
          "test1:0005"=>"e",
          "test1:0004"=>"d",
          "test1:0003"=>"c",
          "test1:0002"=>"b",
          "test1:0001"=>"a"
        })
      end

      it 'returns enumerable' do
        expect(@rocksdb.reverse_each_pair)
          .to be_a(Enumerable)
      end
    end

    context "each_prefix" do
      it 'iterates over keys and values of given prefix' do
        @rocksdb.put("test0:0000", "z")
        @rocksdb.put("test2:0000", "u")
        result = {}

        @rocksdb.each_prefix("test1") do |key, value|
          result[key] = value
        end

        expect(result).to eq({
          "test1:0001" => "a",
          "test1:0002" => "b",
          "test1:0003" => "c",
          "test1:0004" => "d",
          "test1:0005" => "e",
        })
      end

      it 'returns enumerable' do
        expect(@rocksdb.each_prefix("test1"))
          .to be_a(Enumerable)
      end
    end

    context "each_range" do
      it 'iterates over keys and values of given range' do
        @rocksdb.put("test0:0001", "-1")
        @rocksdb.put("test2:multi3", "f")

        result = {}

        @rocksdb.each_range("test1:0002", "test1:0004") do |key, value|
          result[key] = value
        end

        expect(result).to eq({
          "test1:0002" => "b",
          "test1:0003" => "c",
          "test1:0004" => "d"
        })
      end

      it 'returns enumerable' do
        expect(@rocksdb.each_range("test1:0002", "test1:0004"))
          .to be_a(Enumerable)
      end
    end
  end

  it 'should seek to first' do
    @iterator.seek_to_first

    expect(@iterator.key).to eq "test1:0001"
    expect(@iterator.value).to eq "a"
  end

  it 'should seek to last' do
    @iterator.seek_to_last

    expect(@iterator.key).to eq "test1:0005"
    expect(@iterator.value).to eq "e"
  end

  it 'should seek to position' do
    @iterator.seek "test1:0003"

    expect(@iterator.key).to eq "test1:0003"
    expect(@iterator.value).to eq "c"
  end

  it 'should seek to previous' do
    @iterator.seek_to_previous "test1:0004"

    expect(@iterator.key).to eq "test1:0004"
    expect(@iterator.value).to eq "d"
  end

  it 'should go forward' do
    @iterator.seek_to_first
    @iterator.next

    expect(@iterator.key).to eq "test1:0002"
    expect(@iterator.value).to eq "b"
  end

  it 'should go back' do
    @iterator.seek_to_last
    @iterator.previous

    expect(@iterator.key).to eq "test1:0004"
    expect(@iterator.value).to eq "d"
  end

  it 'should iterate all the way to the end' do
    result = {}
    @iterator.seek_to_first

    while @iterator.valid?
      result[@iterator.key] = @iterator.value
      @iterator.next
    end

    expect(result).to eq ({
      "test1:0001" => "a",
      "test1:0002" => "b",
      "test1:0003" => "c",
      "test1:0004" => "d",
      "test1:0005" => "e"
    })
  end

  after do
    @rocksdb.close
  end
end
