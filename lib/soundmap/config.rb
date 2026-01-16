# frozen_string_literal: true

module Soundmap
  module Config
    # Barcelona approximate bounding box (SW and NE corners)
    # lat, lng
    BARCELONA_SW = [41.3200, 2.0520]
    BARCELONA_NE = [41.4700, 2.2300]

    DEFAULT_ZOOM = 14
    DEFAULT_BASEMAP = :carto_light

    def self.bbox
      west  = BARCELONA_SW[1]
      south = BARCELONA_SW[0]
      east  = BARCELONA_NE[1]
      north = BARCELONA_NE[0]
      [west, south, east, north]
    end
  end
end
