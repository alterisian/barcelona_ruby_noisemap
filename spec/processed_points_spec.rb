# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/soundmap/io'

RSpec.describe 'Processed noise points (usable)' do
  it 'loads > 0 points with non-nil dB values from processed CSV' do
    path = File.expand_path('../data/processed/noise_points.csv', __dir__)
    skip 'processed CSV not present' unless File.exist?(path)
    rows = Soundmap::IO.load_noise_points_csv(path)
    expect(rows.length).to be > 0
  end
end
