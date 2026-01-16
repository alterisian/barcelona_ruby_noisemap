# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/soundmap/config'

RSpec.describe Soundmap::Config do
  it 'provides a bbox array [W,S,E,N]' do
    w, s, e, n = described_class.bbox
    expect(w).to be < e
    expect(s).to be < n
  end

  it 'has sane default zoom' do
    expect(Soundmap::Config::DEFAULT_ZOOM).to be_between(10, 18).inclusive
  end
end
