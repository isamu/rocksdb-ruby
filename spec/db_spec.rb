require 'spec_helper'
require "RocksDB"

describe RocksDB do
  before do
    @rockdb = RocksDB.new "/tmp/file"
  end

  it 'should get data' do
    @rockdb.put("test:read", "1")
    @rockdb.get("test:read").should eq "1"
  end

  it 'should put data' do 
    @rockdb.put("test:put", "2").should be_true
    @rockdb.get("test:put").should eq "2"
  end

  it 'should delete data' do 
    @rockdb.put("test:delete", "3")
    @rockdb.get("test:delete").should eq "3"

    @rockdb.delete("test:delete").should be_true
    @rockdb.get("test:delete").should be_empty
  end

  after do
    @rockdb.close
  end

end
