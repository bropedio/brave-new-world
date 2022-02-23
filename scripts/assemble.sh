#!/bin/bash

rom_path="$1"

# Load in environment variables
source "./settings.sh"

# Helpers
assemble () {
  "${XKAS_PATH[@]}" $1 ../$rom_path
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
