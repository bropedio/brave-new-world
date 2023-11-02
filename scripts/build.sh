#!/bin/bash

rom_path="$1"
version="$2"
temp="../temp"
temp_rom="${temp}/temp_rom.sfc"

# Load in environment variables
source "./settings.sh"

# Create/Replace temporary directory
if [ -d "$temp" ]; then rm -r "$temp"; fi
mkdir "$temp"

# Copy source ROM and apply IPS patches
cp "$FF6_PATH" "$rom_path"
./patch.sh "$rom_path"

# Decompress all compressed sections that need modification
./lzss.sh decode "$rom_path"

# Assemble entire asm/banks directory (including temporary f0.asm)
./assemble.sh "$rom_path"

# Compress f0.asm sections into new compressed binaries
./lzss.sh encode "$rom_path"

# Rerun assembly with newly compressed binaries available
./assemble.sh "$rom_path"

# Truncate end of assembled file to remove decompressed ASM in F0
dd if="$rom_path" of="$temp_rom" ibs=1m count=3
mv "$temp_rom" "$rom_path"

node ./checksum.js "$rom_path"
./create_patches.sh "$rom_path" "$version"

# Remove temporary directory
rm -r "$temp"
