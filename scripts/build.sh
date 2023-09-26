#!/bin/bash

rom_path="$1"
version="$2"
tmp_path=${rom_path}__tmp.sfc

# Load in environment variables
source "./settings.sh"

cp "$FF6_PATH" "$rom_path"
./patch.sh "$rom_path"

# Compile compressed binaries with temporary copy
cp "$rom_path" "$tmp_path"
./assemble.sh "$tmp_path"
./compress.sh "$tmp_path"

# Real assembly step, with newly compressed binaries available
./assemble.sh "$rom_path"

# Truncate end of assembled file to remove decompressed ASM in F0
dd if="$rom_path" of="$tmp_path" ibs=1m count=3
mv "$tmp_path" "$rom_path"

node ./checksum.js "$rom_path"
./create_patches.sh "$rom_path" "$version"
