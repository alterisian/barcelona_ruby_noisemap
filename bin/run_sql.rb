#!/usr/bin/env ruby
# frozen_string_literal: true
require 'sqlite3'
path = File.expand_path(File.join(__dir__, '..', 'data', 'raw', 'download'))
sql = ARGV.join(' ')
abort('Provide SQL as arguments') if sql.strip.empty?
puts "DB: #{path}"
puts "SQL> #{sql}"
begin
  db = SQLite3::Database.new(path)
  db.results_as_hash = true
  rows = db.execute(sql)
  if rows.empty?
    puts "(no rows)"
  else
    rows.each { |r| puts r.inspect }
  end
rescue SQLite3::Exception => e
  warn "Error: #{e.message}"
  exit 1
end
