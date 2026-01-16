#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative '../lib/soundmap/gpkg_sampler'

points = [
  [2.1700, 41.3870, 'Pl. Catalunya'],
  [2.1920, 41.4036, 'Sagrada Família'],
  [2.1744, 41.4037, 'Passeig de Gràcia']
]

path = File.expand_path('../data/raw/2022_Raster_Ferrocarrils_Lden_Mapa_Estrategic_Soroll_BCN.gpkg', __dir__)
abort("GeoPackage not found at #{path}") unless File.exist?(path)

sampler = Soundmap::GpkgSampler.new(path)

puts "Debug sampling at known points:" 
points.each do |lon, lat, name|
  val = sampler.sample_db_at(lon, lat)
  puts "%s: lon=%.4f lat=%.4f => dB=%s" % [name, lon, lat, val.inspect]
end
