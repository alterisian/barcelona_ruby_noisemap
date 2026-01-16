#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'libgd_gis'
require 'gd/gis'
require 'gd/gis/style/light'

require_relative '../lib/soundmap/config'
require_relative '../lib/soundmap/noise_scale'

OUT = File.expand_path('../output/mock_noise_barcelona.png', __dir__)
Dir.mkdir(File.dirname(OUT)) unless Dir.exist?(File.dirname(OUT))

# Mock a few noisy points around central BCN (lon, lat) with dB
points = [
  { lon: 2.1700, lat: 41.3870, db: 78 }, # Pl. Catalunya
  { lon: 2.1920, lat: 41.4036, db: 68 }, # Sagrada Família
  { lon: 2.1744, lat: 41.4037, db: 60 }, # Passeig de Gràcia
  { lon: 2.1800, lat: 41.3750, db: 55 }, # La Rambla
  { lon: 2.1995, lat: 41.3925, db: 48 }  # Arc de Triomf
]

west, south, east, north = Soundmap::Config.bbox
zoom = Soundmap::Config::DEFAULT_ZOOM

map = GD::GIS::Map.new(bbox: [west, south, east, north], zoom: zoom, basemap: Soundmap::Config::DEFAULT_BASEMAP)
map.style = GD::GIS::Style::LIGHT

# Build a colored icon per bucket to reuse
require 'gd'
icons = {}
Soundmap::NoiseScale::COLORS.each_with_index do |rgb, idx|
  size = 24
  img = GD::Image.new(size, size)
  img.alpha_blending = true
  img.save_alpha = true
  transparent = GD::Color.rgba(0,0,0,0)
  img.filled_rectangle(0,0,size,size,transparent)
  color = GD::Color.rgb(*rgb)
  cx = size/2
  cy = size/2
  r  = 8
  img.filled_arc(cx, cy, r*2, r*2, 0, 360, color)
  icons[idx] = img
end

# Adapter for PointsLayer
map.add_points(points,
  lon: ->(r){ r[:lon] },
  lat: ->(r){ r[:lat] },
  icon: nil,
  label: ->(r){ "#{r[:db]} dB" },
  font: nil,
  size: 12,
  color: [20,20,20]
)

# Override render to color per point by re-copying icons after base render
orig_render = map.method(:render)
def map.render_with_colored_markers(points, icons)
  r = render_without_overlay
  proj = lambda { |lon, lat| GD::GIS::Projection.lonlat_to_global_px(lon, lat, @zoom) }
  origin_x = @basemap.instance_variable_get(:@x_min) * GD::GIS::Map::TILE_SIZE
  origin_y = @basemap.instance_variable_get(:@y_min) * GD::GIS::Map::TILE_SIZE
  points.each do |p|
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

def map.render_without_overlay
  render
end

class << map
  alias_method :render_without_overlay, :render
  alias_method :render, :render_with_colored_markers
end

map.render(points, icons)
map.save(OUT)
puts "Wrote #{OUT}"
