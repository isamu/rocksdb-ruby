# -*- coding: utf-8 -*-
require 'spec_helper'
require "RocksDB"

describe RocksDB do
  before do
    @rocksdb = RocksDB::DB.new "/tmp/file"
  end

  it 'should use iterator' do
    iterator = @rocksdb.new_iterator

    iterator.seek_to_first
    
    expect(iterator.valid).to be true
    while(iterator.valid)
      expect(iterator.value).not_to be_empty
      expect(iterator.key).not_to be_empty
      iterator.next
    end
    iterator.close
  end

  it 'should seek iterator' do
    iterator = @rocksdb.new_iterator

    iterator.seek("test:put")
    
    iterator.valid
    expect(iterator.value).to eq "2"
    expect(iterator.key).to eq "test:put"

    iterator.close
  end

  after do
    @rocksdb.close
  end
end
