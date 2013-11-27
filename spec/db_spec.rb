require 'spec_helper'
require "RocksDB"

describe RocksDB do
  before do
    @rockdb = RocksDB::DB.new "/tmp/file"
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

  it 'should get multi data' do
    @rockdb.put("test:multi1", "a")
    @rockdb.put("test:multi2", "b")
    @rockdb.put("test:multi3", "c")

    res = @rockdb.multi_get(["test:multi1", "test:multi2", "test:multi3"])
    p res
  end

  after do
    @rockdb.close
  end

end
