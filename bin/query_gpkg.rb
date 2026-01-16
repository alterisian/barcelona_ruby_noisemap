#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sqlite3'

# Prefer Lden file if present; allow override via ARGV[0] or ENV['GPKG']
arg_path = ARGV[0]
lden = File.expand_path(File.join(__dir__, '..', 'data', 'raw', '2022_Raster_Ferrocarrils_Lden_Mapa_Estrategic_Soroll_BCN.gpkg'))
default = File.expand_path(File.join(__dir__, '..', 'data', 'raw', 'download'))
DB_PATH = File.expand_path(arg_path || ENV['GPKG'] || (File.exist?(lden) ? lden : default))

puts "DB: #{DB_PATH}"

begin
  db = SQLite3::Database.new(DB_PATH)
  db.results_as_hash = true

  sql1 = "SELECT table_name, data_type FROM gpkg_contents;"
  puts "SQL> #{sql1}"
  rows1 = db.execute(sql1)
  rows1.each { |r| puts "  table_name=#{r['table_name']} data_type=#{r['data_type']}" }
  puts

  coverage_table = rows1.find { |r| r['data_type'] == '2d-gridded-coverage' }&.fetch('table_name', nil)
  puts "coverage_table=#{coverage_table.inspect}"

  sql2 = "SELECT name FROM sqlite_master WHERE type='table';"
  puts "SQL> #{sql2}"
  rows2 = db.execute(sql2)
  rows2.each { |r| puts "  table=#{r['name']}" }
  puts

  if coverage_table
    max_zoom_sql = "SELECT zoom_level FROM gpkg_tile_matrix WHERE table_name=? ORDER BY zoom_level DESC LIMIT 1;"
    puts "SQL> #{max_zoom_sql} [#{coverage_table}]"
    max_zoom_row = db.get_first_row(max_zoom_sql, [coverage_table])
    max_zoom = max_zoom_row && max_zoom_row['zoom_level']
    puts "  max_zoom=#{max_zoom.inspect}"

    sample_sql = "SELECT zoom_level, tile_column, tile_row, length(tile_data) AS blob_len FROM \"#{coverage_table}\" WHERE zoom_level = ? LIMIT 5;"
    puts "SQL> #{sample_sql} [#{max_zoom}]"
    rows3 = db.execute(sample_sql, [max_zoom])
    rows3.each do |r|
      puts "  z=#{r['zoom_level']} x=#{r['tile_column']} y=#{r['tile_row']} blob_len=#{r['blob_len']}"
    end
  end
rescue SQLite3::Exception => e
  warn "Error: #{e.message}"
  warn e.backtrace.join("\n")
  exit 1
end
