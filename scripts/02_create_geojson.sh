#!/bin/bash -e

rm -r out || true
mkdir out

# N02-23_GML.zip is unzipped here
jq -c '
  .features[] | {
    type: "Feature", 
    geometry: .geometry,
    properties: {
      rr_code: .properties.N02_001 | tonumber, 
      inst_code: .properties.N02_002 | tonumber, 
      name: .properties.N02_003,
      oper_name: .properties.N02_004
    }
  }' ./data/utf8/N02-23_RailroadSection.geojson > ./out/railroad_section_detail.ndgeojson

ogr2ogr -f GeoJSON ./out/railroad_section_detail.geojson ./out/railroad_section_detail.ndgeojson

# 線路名・運営者が入っていないデータを作成
# simplify や統合の時に使われる（低ズーム）
jq -c '
  .features[] | {
    type: "Feature", 
    geometry: .geometry,
    properties: {
      rr_code: .properties.N02_001 | tonumber, 
      inst_code: .properties.N02_002 | tonumber,
    }
  }' ./data/utf8/N02-23_RailroadSection.geojson > ./out/railroad_section_overview.ndgeojson

# simple simplify using ogr2ogr
ogr2ogr -f GeoJSON ./out/railroad_section_overview_simple.geojson ./out/railroad_section_overview.ndgeojson \
  -dialect SQLite \
  -sql "SELECT ST_Union(geometry) as geometry, rr_code, inst_code FROM railroad_section_overview GROUP BY rr_code, inst_code" \
  -simplify 0.01

jq -c '
  .features[] | {
    type: "Feature", 
    geometry: .geometry,
    properties: {
      rr_code: .properties.N02_001 | tonumber, 
      inst_code: .properties.N02_002 | tonumber, 
      rr_name: .properties.N02_003,
      oper_name: .properties.N02_004,
      name: .properties.N02_005,
      id: .properties.N02_005c | tonumber,
      group_id: .properties.N02_005g | tonumber,
    }
  }' ./data/utf8/N02-23_Station.geojson > ./out/station_detail.ndgeojson
ogr2ogr -f GeoJSON ./out/station_detail.geojson ./out/station_detail.ndgeojson

