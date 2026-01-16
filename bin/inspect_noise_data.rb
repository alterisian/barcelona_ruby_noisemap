#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'fileutils'

RAW_DIR = File.expand_path('../data/raw', __dir__)
files = Dir.glob(File.join(RAW_DIR, '**', '*')).select { |f| File.file?(f) }

if files.empty?
  puts "No files in #{RAW_DIR}."
  exit 0
end

files.each do |f|
  ext = File.extname(f).downcase
  kind = case ext
  when '.tif', '.tiff' then 'raster-geotiff'
  when '.asc'          then 'raster-ascii-grid'
  when '.shp'          then 'vector-shapefile'
  when '.geojson', '.json' then 'vector-geojson'
  when '.csv'          then 'csv'
  else 'unknown'
  end
  puts "#{f} => #{kind}"
end
