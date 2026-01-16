Barcelona Sound Map — TODO

 Confirm Barcelona bounding box (SW / NE latitude + longitude)

 Store bounding box as constants in Ruby

 Create minimal Ruby script

 Install and require the new Ruby map-drawing library

 Render an empty map using the Barcelona bounding box

 Export map as PNG or SVG

 Find Barcelona Strategic Noise Map dataset (official source)

 Decide which noise data to use (day / night)

 Download raw noise data

 Inspect data format (CSV, GeoJSON, raster, etc.)

 Convert noise data into lat/lng points or polygons

 Filter noise data to Barcelona bounding box

 Reduce data volume if needed (sampling / aggregation)

 Decide visual representation (points vs polygons)

 Define dB thresholds (quiet → loud)

 Define colour scale for noise levels

 Draw noise layer onto map

 Adjust opacity so base map is visible

 Add simple legend explaining colours

 Add barrio boundaries (optional)

 Add barrio labels (optional)

 Add major roads only (optional)

 Spot-check known loud areas

 Spot-check known quiet streets

 Tweak thresholds / colours if results feel wrong

 Clean up code

 Extract config (bounding box, colours, thresholds)

 Commit working version

 Export final image

 References:

 https://rubystacknews.com/2026/01/07/ruby-can-now-draw-maps-and-i-started-with-ice-cream/ 
 https://rubygems.org/gems/libgd-gis 
 https://datos.gob.es/en/catalogo/l01080193-mapas-de-ruido-raster-del-mapa-estrategico-de-ruido-de-la-ciudad-de-barcelona?utm_source=chatgpt.com

 Output:

 Build a system in ruby, with some leightweight happy path first tests in rspec, then some edge cases. 
 A map of Barcelona, with the sound data displayed on to it, so we can see which barrios and streets are the quietest. 
 It is ok to have intermediate steps, where we prove the gem works on our system, see a map for Barcelona with just streets, and so on. This is defined in our todo list above. 

 Setup log (what we actually did):

 - Created Gemfile with `libgd-gis` and `rspec`.
 - Installed system dependencies for native build: GD headers and tools (e.g., `libgd-dev`, build-essential/pkg-config on Debian/Ubuntu).
 - Ran `bundle install` successfully. `libgd-gis` and dependencies installed.
 - Added render script and produced initial map output.
 - Adjusted zoom to 14 to focus on central Barcelona; ensured outputs are saved under `output/` within the project.
 - Added NoiseScale module with thresholds/colors and tests; created a mock noise overlay renderer to validate points layer integration and icon coloring.
 - Added CSV ingestion (`Soundmap::IO`) with tests; sample CSV-driven overlay renders successfully.
 - Added downloader (`bin/download_noise_data.rb`) and inspector (`bin/inspect_noise_data.rb`) for the official dataset; created `data/raw` and `data/processed` directories.