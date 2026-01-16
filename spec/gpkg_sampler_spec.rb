# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/soundmap/gpkg_sampler'

RSpec.describe Soundmap::GpkgSampler do
  it 'returns a dB value for known central points when data is present' do
    path = File.expand_path('../data/raw/download', __dir__)
    skip 'gpkg not downloaded' unless File.exist?(path)
    sampler = described_class.new(path)
    pts = [
      [2.1700, 41.3870], # Pl. Catalunya
      [2.1920, 41.4036], # Sagrada Família
      [2.1744, 41.4037], # Passeig de Gràcia
    ]
    values = pts.map { |lon, lat| sampler.sample_db_at(lon, lat) }.compact
    expect(values.length).to be > 0
  end
end
