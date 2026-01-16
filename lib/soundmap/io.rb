# frozen_string_literal: true

require 'csv'

module Soundmap
  module IO
    # Load noise points from a CSV with headers: lat,lng,db
    # Returns array of { lat:, lon:, db: }
    def self.load_noise_points_csv(path)
      rows = []
      CSV.foreach(path, headers: true) do |row|
        lat = row['lat']&.to_f
        lon = row['lng']&.to_f || row['lon']&.to_f || row['long']&.to_f
        db  = row['db']&.to_f || row['dB']&.to_f
        next if lat.nil? || lon.nil? || db.nil?
        rows << { lat: lat, lon: lon, db: db }
      end
      rows
    end
  end
end
