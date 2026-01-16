#!/usr/bin/env ruby
# frozen_string_literal: true
require 'bundler/setup'
require 'sqlite3'

path = ARGV[0] || File.expand_path('../data/raw/download', __dir__)
abort("Provide path to .gpkg") unless File.exist?(path)

db = SQLite3::Database.new(path)
rows = db.execute("SELECT table_name, data_type, identifier FROM gpkg_contents")
rows.each do |t, type, ident|
  puts "#{t}	#{type}	#{ident}"
end
