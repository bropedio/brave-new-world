#!/bin/bash

IPS_PATH="$1"

BASE_FF6_N="../roms/ff3-1.1-n.sfc"
BASE_FF6_H="../roms/ff3-1.1-h.sfc"
PATCHED_H="../roms/temp-patched-h.sfc"
PATCHED_N="../roms/temp-patched-n.sfc"

apply_patch () {
  "$IPS_PATH" --apply "$1" "$BASE_FF6_H" "$PATCHED_H"
}
create_patch () {
  "$IPS_PATH" --create --ips "$BASE_FF6_N" "$PATCHED_N" "$1"
}

cd ../h-ips
for file in *.ips
do
  apply_patch $file
  tail -b +2 "$PATCHED_H" > "$PATCHED_N"
  create_patch "../ips/$file"
  rm "$PATCHED_H" "$PATCHED_N"
done
