# Barcelona Sound Map (Ruby)

Progress: ~55% complete — ~3h today, ~15k–30k tokens

This project renders a Barcelona basemap and overlays Strategic Noise Map data using Ruby.

- Mapping: libgd-gis (GD-based)
- Tests: RSpec
- Data: Barcelona Strategic Noise Map (GeoPackage, tiled raster)

## What works
- Project scaffolded with Gemfile and bundling
- Base map renders with bbox and zoom
- Noise color scale and CSV overlay (mock/sample) with tests
- GeoPackage download and inspection scripts
- New Lden GeoPackage saved with its proper filename
- Sampler wired to query gpkg tables and fetch tile blobs

## What’s in progress
- Correct tile x/y and px/py computation using gpkg bounds/dimensions (SRS-aware)
- Mapping RGB in tiles to dB values
- Filling processed CSV with sampled points and rendering overlay

## TODO (from Barcelona Sound Map — TODO.md)
- [x] Confirm Barcelona bounding box (SW / NE latitude + longitude)
- [x] Store bounding box as constants in Ruby
- [x] Create minimal Ruby script
- [x] Install and require the new Ruby map-drawing library
- [x] Render an empty map using the Barcelona bounding box
- [x] Export map as PNG or SVG
- [x] Find Barcelona Strategic Noise Map dataset (official source)
- [x] Decide which noise data to use (day / night) — using Lden first
- [x] Download raw noise data
- [x] Inspect data format (GeoPackage raster)
- [ ] Convert noise data into lat/lng points or polygons (sampling raster tiles)
- [ ] Filter noise data to Barcelona bounding box
- [~] Reduce data volume if needed (sampling / aggregation)
- [x] Decide visual representation (points)
- [x] Define dB thresholds (quiet → loud)
- [x] Define colour scale for noise levels
- [ ] Draw noise layer onto map (from real data)
- [ ] Adjust opacity so base map is visible
- [ ] Add simple legend explaining colours
- [ ] Add barrio boundaries (optional)
- [ ] Add barrio labels (optional)
- [ ] Add major roads only (optional)
- [ ] Spot-check known loud areas
- [ ] Spot-check known quiet streets
- [ ] Tweak thresholds / colours if results feel wrong
- [x] Clean up code (ongoing)
- [x] Extract config (bounding box, colours, thresholds)
- [x] Commit working version
- [ ] Export final image

## How to run
- Inspect GeoPackage:
  - bundle exec ./bin/query_gpkg.rb
- Debug sample a few points:
  - bundle exec ./bin/debug_sample_tile.rb
- Render base map:
  - bundle exec ./bin/render_blank_map.rb

## Notes
- The official raster is tiled in a GeoPackage. We sample the tile at the point location and map RGB to dB.
- If needed, we’ll switch to a vector isophones dataset to simplify sampling.
