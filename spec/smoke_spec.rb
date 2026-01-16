# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'libgd-gis loads' do
  it 'requires and exposes GD::GIS constants' do
    expect { require 'libgd_gis' }.not_to raise_error
    expect { require 'gd/gis' }.not_to raise_error
    expect(defined?(GD::GIS)).to eq('constant')
  end
end
