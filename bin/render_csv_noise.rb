#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'libgd_gis'
require 'gd/gis'
require 'gd/gis/style/light'

require_relative '../lib/soundmap/config'
require_relative '../lib/soundmap/noise_scale'
require_relative '../lib/soundmap/io'

IN  = ARGV[0] || File.expand_path('../data/sample/noise_points.csv', __dir__)
OUT = File.expand_path('../output/csv_noise_barcelona.png', __dir__)
Dir.mkdir(File.dirname(OUT)) unless Dir.exist?(File.dirname(OUT))

rows = Soundmap::IO.load_noise_points_csv(IN)

west, south, east, north = Soundmap::Config.bbox
zoom = Soundmap::Config::DEFAULT_ZOOM

map = GD::GIS::Map.new(bbox: [west, south, east, north], zoom: zoom, basemap: Soundmap::Config::DEFAULT_BASEMAP)
map.style = GD::GIS::Style::LIGHT

# Create per-bucket icons
require 'gd'
icons = {}
Soundmap::NoiseScale::COLORS.each_with_index do |rgb, idx|
  size = 16
  img = GD::Image.new(size, size)
  img.alpha_blending = true
  img.save_alpha = true
  transparent = GD::Color.rgba(0,0,0,0)
  img.filled_rectangle(0,0,size,size,transparent)
  color = GD::Color.rgb(*rgb)
  cx = size/2
  cy = size/2
  r  = 6
  img.filled_arc(cx, cy, r*2, r*2, 0, 360, color)
  icons[idx] = img
end

# Render base + overlay icons colored by dB bucket
class << map
  alias_method :render_without_overlay, :render
  def render_with_overlay(rows, icons)
    r = render_without_overlay
    proj = lambda { |lon, lat| GD::GIS::Projection.lonlat_to_global_px(lon, lat, @zoom) }
    origin_x = @basemap.instance_variable_get(:@x_min) * GD::GIS::Map::TILE_SIZE
    origin_y = @basemap.instance_variable_get(:@y_min) * GD::GIS::Map::TILE_SIZE
    rows.each do |p|
      xg, yg = proj.call(p[:lon], p[:lat])
      x = (xg - origin_x).round
      y = (yg - origin_y).round
      bucket = Soundmap::NoiseScale.bucket_for(p[:db])
      icon = icons[bucket]
      w = icon.width
      h = icon.height
      @image.copy(icon, x - w/2, y - h/2, 0,0,w,h)
    end
    r
  end
end

def map.render_overlay(rows, icons)
  render_with_overlay(rows, icons)
end

map.render_overlay(rows, icons)
map.save(OUT)
puts "Read #{rows.length} rows -> Wrote #{OUT}"
