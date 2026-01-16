# frozen_string_literal: true

require 'spec_helper'
require 'csv'

RSpec.describe 'Noise extractor' do
  it 'writes a CSV with headers and rows' do
    path = File.expand_path('../data/processed/noise_points.csv', __dir__)
    skip 'processed CSV not present' unless File.exist?(path)
    rows = CSV.read(path, headers: true)
    expect(rows.headers).to include('lat', 'lng', 'db')
    expect(rows.length).to be > 10
  end
end
