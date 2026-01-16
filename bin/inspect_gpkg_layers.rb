#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'open3'
require 'json'

RAW_DIR = File.expand_path('../data/raw', __dir__)
path = ARGV[0] || Dir.glob(File.join(RAW_DIR, '*')).find { |f| File.file?(f) }
abort("Provide a .gpkg path or place one under #{RAW_DIR}") unless path

# If file has no extension but is GeoPackage, proceed anyway
puts "Inspecting #{path}"

sql = <<~SQL
  SELECT table_name, data_type, identifier, min_x, min_y, max_x, max_y
  FROM gpkg_contents;
SQL

cmd = ["sqlite3", "-readonly", path, sql]
stdout, stderr, status = Open3.capture3(*cmd)
if !status.success?
  warn "sqlite3 error: #{stderr}"
  exit 1
end

rows = stdout.lines.map { |l| l.strip.split('|') }
rows.each do |t, type, ident, minx, miny, maxx, maxy|
  puts "- #{t} (#{type}) ident=#{ident} bbox=[#{minx},#{miny},#{maxx},#{maxy}]"
end
