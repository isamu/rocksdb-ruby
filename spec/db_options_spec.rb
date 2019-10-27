# -*- coding: utf-8 -*-
require 'spec_helper'
require "rocksdb"

describe RocksDB, :focus do
  context "options" do
    let(:rocksdb) { RocksDB.open temp_db_path, "WAL_size_limit_MB=16" }

    it "returns RocksDB options as a hash" do
      expect(rocksdb.options).to be_a Hash
    end

    it "returns database options" do
      expect(rocksdb.options).to include("use_fsync")
    end

    it "returns column family options" do
      expect(rocksdb.options).to include("table_factory")
    end
  end

  context "open" do
    it 'should work without options' do
      rocksdb = RocksDB.open temp_db_path

      expect(rocksdb).to be_open
    end

    it 'should set valid string options' do
      rocksdb = RocksDB.open temp_db_path, "WAL_size_limit_MB=16"

      expect(rocksdb.options["WAL_size_limit_MB"])
        .to eq "16"
    end

    it 'should set valid hash options' do
      rocksdb = RocksDB.open temp_db_path, WAL_size_limit_MB: "42"

      expect(rocksdb.options["WAL_size_limit_MB"])
        .to eq "42"
    end

    it 'should not set invalid option' do
      expect { RocksDB.open temp_db_path, "Omg_totaly_fake=4" }
        .to raise_error(RocksDB::StatusError)
    end

    it 'should not segfault on gibberish' do
      expect { RocksDB.open temp_db_path, "%28324!@4912=4AAS\00DAD2-;1421" }
        .to raise_error(RocksDB::StatusError)
    end
  end
end
