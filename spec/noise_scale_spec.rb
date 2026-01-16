# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/soundmap/noise_scale'

RSpec.describe Soundmap::NoiseScale do
  it 'assigns cooler colors to quiet and hotter to loud' do
    expect(described_class.color_for(40)).to eq([153,204,255])
    expect(described_class.color_for(60)).to eq([255,221,102])
    expect(described_class.color_for(80)).to eq([230,57,70])
  end

  it 'buckets correctly at thresholds' do
    expect(described_class.bucket_for(45)).to eq(0)
    expect(described_class.bucket_for(46)).to eq(1)
    expect(described_class.bucket_for(55)).to eq(1)
    expect(described_class.bucket_for(56)).to eq(2)
  end
end
