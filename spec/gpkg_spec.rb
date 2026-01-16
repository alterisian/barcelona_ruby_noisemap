# frozen_string_literal: true

require 'spec_helper'
require 'sqlite3'

RSpec.describe 'GeoPackage contents' do
  it 'lists at least one 2d-gridded-coverage layer' do
    path = File.expand_path('../data/raw/download', __dir__)
    skip 'gpkg not downloaded' unless File.exist?(path)
    db = SQLite3::Database.new(path)
    rows = db.execute("SELECT table_name FROM gpkg_contents WHERE data_type='2d-gridded-coverage'")
    expect(rows).not_to be_empty
  end
end
