#!/bin/bash

rom_path="$1"
version="$2"
temp_rom="../temp/temp_rom.sfc"

# Load in environment variables
source "./settings.sh"

# Main
rm -r "../temp"
mkdir "../temp"

cp "$FF6_PATH" "$rom_path"
./patch.sh "$rom_path"

# Compile compressed binaries with temporary copy
cp "$rom_path" "$temp_rom"
./assemble.sh "$temp_rom"
./compress.sh "$temp_rom"

# Real assembly step, with newly compressed binaries available
./assemble.sh "$rom_path"

# Truncate end of assembled file to remove decompressed ASM in F0
dd if="$rom_path" of="$temp_rom" ibs=1m count=3
mv "$temp_rom" "$rom_path"

node ./checksum.js "$rom_path"
./create_patches.sh "$rom_path" "$version"
