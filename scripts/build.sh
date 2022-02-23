#!/bin/bash

rom_path="$1"
version="$2"

# Load in environment variables
source "./settings.sh"

./patch.sh "$rom_path"
./assemble.sh "$rom_path"
./create_patches.sh "$rom_path" "$version"
