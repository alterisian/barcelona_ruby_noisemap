#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'open-uri'
require 'fileutils'
require 'uri'

RAW_DIR = File.expand_path('../data/raw', __dir__)
FileUtils.mkdir_p(RAW_DIR)

url = ARGV[0] || ENV['NOISE_DATA_URL']
abort("Usage: download_noise_data.rb <URL> or set NOISE_DATA_URL" ) unless url

uri = URI.parse(url)
filename = File.basename(uri.path)
filename = 'noise_data' if filename.nil? || filename.empty?
path = File.join(RAW_DIR, filename)

puts "Downloading #{url} -> #{path}"

URI.open(url) do |io|
  File.binwrite(path, io.read)
end

puts "Saved #{path} (#{File.size(path)} bytes)"
