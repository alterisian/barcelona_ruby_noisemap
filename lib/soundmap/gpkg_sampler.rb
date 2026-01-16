# frozen_string_literal: true

require 'sqlite3'
require 'stringio'
require 'gd'

module Soundmap
  class GpkgSampler
    def initialize(path)
      @db = SQLite3::Database.new(path)
      @db.results_as_hash = true
      @coverage_table = find_coverage_table
    end

    # Core: working query path: use gpkg_tile_matrix to choose zoom, then fetch blob from coverage table
    def sample(lon, lat)
      return nil unless @coverage_table
      z = highest_zoom_for(@coverage_table)
      row = nil
      x = y = nil
      tms = tile_matrix_set_bounds(@coverage_table)
      while z >= 0
        dims = matrix_dims(@coverage_table, z)
        break unless tms && dims
        x, y = lonlat_to_tile_gpkg(lon, lat, tms, dims)
        STDERR.puts "[GpkgSampler] coverage=#{@coverage_table} z=#{z} x=#{x} y=#{y}"
        row = @db.get_first_row("SELECT tile_data FROM \"#{@coverage_table}\" WHERE zoom_level=? AND tile_column=? AND tile_row=?", [z, x, y])
        STDERR.puts "[GpkgSampler] blob_present=#{!row.nil?}"
        break if row && row['tile_data']
        z -= 1
      end
      return nil unless row && row['tile_data']
      img = decode_image(row['tile_data'])
      return nil unless img
      dims = matrix_dims(@coverage_table, z)
      tms ||= tile_matrix_set_bounds(@coverage_table)
      px, py = pixel_in_tile_gpkg(lon, lat, tms, dims)
      STDERR.puts "[GpkgSampler] px=#{px} py=#{py}"
      color = img.getPixel(px, py)
      r = img.red(color)
      g = img.green(color)
      b = img.blue(color)
      STDERR.puts "[GpkgSampler] rgb=#{r},#{g},#{b}"
      color_to_db(r, g, b)
    rescue SQLite3::Exception => e
      STDERR.puts "[GpkgSampler] sqlite error: #{e.message}"
      nil
    end

    def sample_db_at(lon, lat)
      sample(lon, lat)
    end

    private

    def find_coverage_table
      row = @db.get_first_row("SELECT table_name FROM gpkg_contents WHERE data_type='2d-gridded-coverage' LIMIT 1")
      row && row['table_name']
    end

    def highest_zoom_for(table)
      row = @db.get_first_row("SELECT zoom_level FROM gpkg_tile_matrix WHERE table_name=? ORDER BY zoom_level DESC LIMIT 1", [table])
      row ? row['zoom_level'].to_i : 6
    end

    def tile_matrix_set_bounds(table)
      row = @db.get_first_row("SELECT srs_id, min_x, min_y, max_x, max_y FROM gpkg_tile_matrix_set WHERE table_name=?", [table])
      return nil unless row
      { srs_id: row['srs_id'].to_i, min_x: row['min_x'].to_f, min_y: row['min_y'].to_f, max_x: row['max_x'].to_f, max_y: row['max_y'].to_f }
    end

    def matrix_dims(table, zoom)
      row = @db.get_first_row("SELECT matrix_width, matrix_height FROM gpkg_tile_matrix WHERE table_name=? AND zoom_level=?", [table, zoom])
      return nil unless row
      { width: row['matrix_width'].to_i, height: row['matrix_height'].to_i }
    end

    def decode_image(blob)
      GD::Image.newFromPngPtr(blob)
    rescue
      GD::Image.newFromJpegPtr(blob)
    rescue
      nil
    end

    def lonlat_to_tile_gpkg(lon, lat, tms, dims)
      if tms[:srs_id] == 4326
        x_ratio = (lon - tms[:min_x]) / (tms[:max_x] - tms[:min_x])
        y_ratio = (tms[:max_y] - lat) / (tms[:max_y] - tms[:min_y])
      else
        rad = Math::PI / 180.0
        x_m = 6378137.0 * lon * rad
        y_m = 6378137.0 * Math.log(Math.tan(Math::PI/4 + lat*rad/2))
        x_ratio = (x_m - tms[:min_x]) / (tms[:max_x] - tms[:min_x])
        y_ratio = (tms[:max_y] - y_m) / (tms[:max_y] - tms[:min_y])
      end
      x = (x_ratio * dims[:width]).floor
      y = (y_ratio * dims[:height]).floor
      [x, y]
    end

    def pixel_in_tile_gpkg(lon, lat, tms, dims, tile_size: 256)
      if tms[:srs_id] == 4326
        x_ratio = (lon - tms[:min_x]) / (tms[:max_x] - tms[:min_x])
        y_ratio = (tms[:max_y] - lat) / (tms[:max_y] - tms[:min_y])
      else
        rad = Math::PI / 180.0
        x_m = 6378137.0 * lon * rad
        y_m = 6378137.0 * Math.log(Math.tan(Math::PI/4 + lat*rad/2))
        x_ratio = (x_m - tms[:min_x]) / (tms[:max_x] - tms[:min_x])
        y_ratio = (tms[:max_y] - y_m) / (tms[:max_y] - tms[:min_y])
      end
      fx = (x_ratio * dims[:width]) % 1.0
      fy = (y_ratio * dims[:height]) % 1.0
      px = (fx * tile_size).floor
      py = (fy * tile_size).floor
      [px, py]
    end

    def color_to_db(r, g, b)
      return 45 if b > 180 && r < 120
      return 65 if r > 220 && g > 200 && b < 180
      return 75 if r > 200 && g < 160
      return 55 if g > 180 && r < 180
      nil
    end
  end
end
