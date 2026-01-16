# frozen_string_literal: true

module Soundmap
  # Maps dB levels to color buckets for visualization
  module NoiseScale
    # Thresholds in dB (exclusive upper bound per bucket except last)
    # Buckets: [ (-inf, QUIET], (QUIET, MODERATE], (MODERATE, BUSY], (BUSY, LOUD], (LOUD, +inf) ]
    QUIET    = 45
    MODERATE = 55
    BUSY     = 65
    LOUD     = 75

    BUCKETS = [QUIET, MODERATE, BUSY, LOUD].freeze

    # Colors per bucket as RGB
    # quiet -> cool, loud -> hot
    COLORS = [
      [153, 204, 255], # <=45  light blue
      [102, 178, 255], # <=55  blue
      [255, 221, 102], # <=65  yellow
      [255, 153, 51],  # <=75  orange
      [230, 57, 70]    # >75   red
    ].freeze

    def self.bucket_for(db)
      BUCKETS.each_with_index do |th, idx|
        return idx if db <= th
      end
      BUCKETS.length # last bucket
    end

    def self.color_for(db)
      COLORS[bucket_for(db)]
    end
  end
end
