# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require_relative '../lib/soundmap/io'

RSpec.describe Soundmap::IO do
  it 'loads noise points from CSV with headers' do
    csv = <<~CSV
      lat,lng,db
      41.385,2.173,65
      41.39,2.18,72
    CSV
    file = Tempfile.new(['noise','.csv'])
    file.write(csv)
    file.flush

    rows = described_class.load_noise_points_csv(file.path)
    expect(rows.length).to eq(2)
    expect(rows.first[:db]).to eq(65.0)
  ensure
    file.close
    file.unlink
  end
end
