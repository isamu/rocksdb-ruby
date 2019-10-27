# -*- coding: utf-8 -*-
require 'spec_helper'
require "rocksdb"

describe RocksDB do
  context "options" do
    it 'should set valid option' do
      expect { RocksDB.open temp_db_path, "compression=kNoCompression" }
        .not_to raise_error
    end

    it 'should not set invalid option' do
      expect { RocksDB.open temp_db_path, "Omg_totaly_fake=4" }
        .to raise_error(RocksDB::StatusError)
    end

    it 'should not segfault on jibberish' do
      expect { RocksDB.open temp_db_path, "%28324!@49124AASDAD21421\00" }
        .to raise_error(RocksDB::StatusError)
    end
  end
end
