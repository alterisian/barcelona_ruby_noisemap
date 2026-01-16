#!/usr/bin/env ruby
# frozen_string_literal: true
require 'sqlite3'

DB_FILE = File.expand_path(File.join(__dir__, '..', 'data', 'raw', 'download'))
RASTER_TABLE = '2022_Raster_Ferrocarrils_Dia_Mapa_Estrategic_Soroll_BCN'

# Target point in Barcelona (Plaça de Catalunya)
target_lat = 41.3870
target_lon = 2.1700

db = SQLite3::Database.new(DB_FILE)
db.results_as_hash = true

# Inspect table columns first
cols = db.execute("PRAGMA table_info(\"#{RASTER_TABLE}\")")
col_names = cols.map { |c| c[1] }
puts "Columns in #{RASTER_TABLE}: #{col_names.inspect}"

if (['x','y','value'] - col_names).empty?
  query = <<~SQL
    SELECT value, x, y
    FROM "#{RASTER_TABLE}"
    ORDER BY ((x - ?) * (x - ?) + (y - ?) * (y - ?)) ASC
    LIMIT 1;
  SQL
  puts "SQL> #{query.strip} [#{target_lon}, #{target_lon}, #{target_lat}, #{target_lat}]"
  row = db.get_first_row(query, [target_lon, target_lon, target_lat, target_lat])
  if row
    noise_value = row['value'] || row[0]
    cell_x = row['x'] || row[1]
    cell_y = row['y'] || row[2]
    puts "Approximate noise at #{target_lat}, #{target_lon} = #{noise_value} dB"
    puts "Nearest raster cell center at #{cell_y}, #{cell_x}"
  else
    puts 'No raster data found near this point.'
  end
else
  puts 'The table does not have x,y,value columns; it appears to be tiled raster storage.'
  puts 'Try querying tiles: SELECT zoom_level, tile_column, tile_row, length(tile_data) FROM "#{RASTER_TABLE}" LIMIT 5;'
end

db.close
