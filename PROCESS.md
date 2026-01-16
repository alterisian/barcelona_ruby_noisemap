# Progress log

## 2026-01-16 13:56

- Downloaded: `data/raw/2022_Raster_Ferrocarrils_Lden_Mapa_Estrategic_Soroll_BCN.gpkg` (~36 MB)
- Inspected contents:
  - SQL: `SELECT table_name, data_type FROM gpkg_contents;`
    - 2022_Raster_Ferrocarrils_Lden_Mapa_Estrategic_Soroll_BCN — 2d-gridded-coverage
    - layer_styles — attributes
  - SQL: `SELECT name FROM sqlite_master WHERE type='table';`
    - Tables: gpkg_spatial_ref_sys, gpkg_contents, gpkg_tile_matrix_set, gpkg_tile_matrix, gpkg_2d_gridded_coverage_ancillary, gpkg_2d_gridded_tile_ancillary, layer_styles, coverage tile table
  - SQL: `SELECT zoom_level FROM gpkg_tile_matrix WHERE table_name=? ORDER BY zoom_level DESC LIMIT 1;` [coverage]
    - max_zoom = 6
  - SQL: `SELECT zoom_level, tile_column, tile_row, length(tile_data) FROM "2022_Raster_Ferrocarrils_Lden_Mapa_Estrategic_Soroll_BCN" WHERE zoom_level=? LIMIT 5;` [6]
    - Sample rows exist: x=0, y=6..10, blob_len ≈ 2.3–7.9 KB

Next steps:
- Point sampler at the Lden file, compute tile x/y using gpkg bounds/dimensions, and print RGB/dB for Plaça de Catalunya.

## 2026-01-16 14:00

- Confirmed Lden GeoPackage tables and tiles via script:
  - SQL: `SELECT table_name, data_type FROM gpkg_contents;` → Lden coverage + layer_styles
  - SQL: `SELECT zoom_level FROM gpkg_tile_matrix WHERE table_name=? ORDER BY zoom_level DESC LIMIT 1;` → max_zoom=6
  - SQL: `SELECT zoom_level, tile_column, tile_row, length(tile_data) FROM "2022_Raster_Ferrocarrils_Lden_Mapa_Estrategic_Soroll_BCN" WHERE zoom_level=? LIMIT 5;` → blobs present
- Sampler wiring in progress to use gpkg bounds/dimensions for tile index and pixel sampling.
- Goal: sample Plaça de Catalunya and log `z/x/y`, `px/py`, `RGB`, and mapped dB.

## 2026-01-16 14:05

- Pointed inspection scripts at Lden file; confirmed max_zoom=6 and blobs present at z=6.
- Next: update sampler to read gpkg bounds (gpkg_tile_matrix_set) and matrix dims (gpkg_tile_matrix) for correct tile x/y, then print RGB/dB at Plaça de Catalunya.