#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'libgd_gis'
require 'gd/gis'
require 'gd/gis/style/light'

# Barcelona approximate bounding box (SW and NE corners)
# Source: general city extents; we can refine later.
BARCELONA_SW = [41.3200, 2.0520] # lat, lng
BARCELONA_NE = [41.4700, 2.2300]

# Image output
OUT = File.expand_path('../output/blank_barcelona.png', __dir__)
Dir.mkdir(File.dirname(OUT)) unless Dir.exist?(File.dirname(OUT))

# Create a map with a light style and no extra layers yet
west  = BARCELONA_SW[1]
south = BARCELONA_SW[0]
east  = BARCELONA_NE[1]
north = BARCELONA_NE[0]

# Choose a zoom that frames the city nicely
zoom = 14

# Initialize map with bbox array and basemap provider
map = GD::GIS::Map.new(bbox: [west, south, east, north], zoom: zoom, basemap: :carto_light)
map.style = GD::GIS::Style::LIGHT
map.render
map.save(OUT)
puts "Wrote #{OUT}"
