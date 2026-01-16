#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'sqlite3'
require 'csv'
require 'stringio'
require 'gd'
require_relative '../lib/soundmap/gpkg_sampler'

require_relative '../lib/soundmap/config'

RAW = File.expand_path('../data/raw/download', __dir__)
OUT = File.expand_path('../data/processed/noise_points.csv', __dir__)

# Choose the main raster table from gpkg_contents (first 2d-gridded-coverage)
db = SQLite3::Database.new(RAW)
rows = db.execute("SELECT table_name FROM gpkg_contents WHERE data_type='2d-gridded-coverage' LIMIT 1")
abort("No 2d-gridded-coverage table found") if rows.empty?
table = rows.first.first

# Fetch bounds and resolution from tile matrix set (global extent)
bounds = db.get_first_row("SELECT min_x, min_y, max_x, max_y FROM gpkg_tile_matrix_set WHERE table_name=?", table)
abort("No bounds for #{table}") unless bounds
min_x, min_y, max_x, max_y = bounds.map(&:to_f)

# Simple sampling: grid N x M across bbox; convert projected coords to lon/lat assuming EPSG:3857
sample_cols = 40
sample_rows = 40

# Helper: inverse WebMercator to lon/lat
RAD_TO_DEG = 180.0 / Math::PI

inv_mercator = lambda do |x, y|
  lon = x * 180.0 / 20037508.34
  lat = Math.atan(Math.sinh(y / 6378137.0)) * RAD_TO_DEG
  [lon, lat]
end

west, south, east, north = Soundmap::Config.bbox

# Clamp to our bbox in projected coords
# Approximate: project our bbox to WebMercator
mercator = lambda do |lon, lat|
  x = lon * 20037508.34 / 180.0
  y = Math.log(Math.tan((90 + lat) * Math::PI / 360.0)) * 6378137.0
  [x, y]
end

bx_min, by_min = mercator.call(west, south)
bx_max, by_max = mercator.call(east, north)

sx_min = [min_x, bx_min].max
sy_min = [min_y, by_min].max
sx_max = [max_x, bx_max].min
sy_max = [max_y, by_max].min

# Determine a reasonable zoom and tile table
tile_row = db.get_first_row("SELECT zoom_level FROM gpkg_tile_matrix WHERE table_name=? ORDER BY zoom_level DESC LIMIT 1", table)
zoom = tile_row ? tile_row[0].to_i : 12

# Find a tile table with columns (zoom_level, tile_column, tile_row, tile_data)
tile_table = nil
candidate_tables = db.execute("SELECT name FROM sqlite_master WHERE type='table'").flatten
candidate_tables.each do |name|
  cols = db.execute("PRAGMA table_info(\"#{name}\")")
  col_names = cols.map { |c| c[1] }
  if (col_names & ["zoom_level","tile_column","tile_row","tile_data"]).size == 4
    tile_table = name
    break
  end
end

def color_to_db(r,g,b)
  # Simple legend mapping: blue->quiet, yellow->mid, orange/red->loud
  if b > 200 && r < 100
    45
  elsif r > 240 && g > 200 && b < 150
    65
  elsif r > 240 && g < 200
    75
  else
    55
  end
end

def lonlat_to_tile(lon, lat, zoom)
  xtile = ((lon + 180.0) / 360.0 * (2 ** zoom)).floor
  ytile = (
    (1.0 - Math.log(Math.tan(lat * Math::PI / 180.0) + 1.0 / Math.cos(lat * Math::PI / 180.0)) / Math::PI) / 2.0 * (2 ** zoom)
  ).floor
  [xtile, ytile]
end

def pixel_in_tile(lon, lat, zoom)
  n = 2.0 ** zoom
  x = (lon + 180.0) / 360.0 * n
  y = (1.0 - Math.log(Math.tan(lat * Math::PI / 180.0) + 1.0 / Math.cos(lat * Math::PI / 180.0)) / Math::PI) / 2.0 * n
  px = ((x - x.floor) * 256).to_i
  py = ((y - y.floor) * 256).to_i
  [px, py]
end

sampler = Soundmap::GpkgSampler.new(RAW)
CSV.open(OUT, 'w') do |csv|
  csv << ["lat","lng","db"]
  sample_cols.times do |i|
    sample_rows.times do |j|
      x = sx_min + (sx_max - sx_min) * (i.to_f / (sample_cols - 1))
      y = sy_min + (sy_max - sy_min) * (j.to_f / (sample_rows - 1))
      lon, lat = inv_mercator.call(x, y)
  db_val = sampler.sample_db_at(lon, lat)

      next if db_val.nil?
      csv << [lat, lon, db_val]
    end
  end
end

puts "Wrote #{OUT}"
