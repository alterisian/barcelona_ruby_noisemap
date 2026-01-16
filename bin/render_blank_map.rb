#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'libgd_gis'
require 'gd/gis'
require 'gd/gis/style/light'
require_relative '../lib/soundmap/config'

# Image output
OUT = File.expand_path('../output/blank_barcelona.png', __dir__)
Dir.mkdir(File.dirname(OUT)) unless Dir.exist?(File.dirname(OUT))

# Create a map with a light style and no extra layers yet
west, south, east, north = Soundmap::Config.bbox
zoom = Soundmap::Config::DEFAULT_ZOOM

map = GD::GIS::Map.new(bbox: [west, south, east, north], zoom: zoom, basemap: Soundmap::Config::DEFAULT_BASEMAP)
map.style = GD::GIS::Style::LIGHT
map.render
map.save(OUT)
puts "Wrote #{OUT}"
