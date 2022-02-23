#!/bin/bash

ROM_PATH=../../roms/test.sfc
WINE_PATH="$1"
XKAS_PATH="$2"

# Helpers
assemble () {
  "$WINE_PATH" "$XKAS_PATH" $1 $ROM_PATH
}
assemble_master () {
  cd ../asm/$1
  assemble $2
  cd ../../scripts
}

# Assemble asm files in synchysi directory one at a time
cd ../asm/synchysi
for file in *.asm
do
  assemble $file
done
cd ../../scripts

# Assemble bropedio asm using master files
assemble_master bropedio-2.0 RC33.asm
assemble_master bropedio-2.1 RC-18.asm
