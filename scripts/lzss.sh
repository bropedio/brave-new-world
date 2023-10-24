#!/bin/bash

temp="../temp"
action="$1"
rom_path="$2"

handle () {
  local encoded_path="$temp/${1}.compressed"
  local decoded_path="$temp/${1}.decompressed"
  local encoded_offset="$2"
  local decoded_offset="$3"

  if [ "$action" = "decode" ]; then
    # Generate both compressed and decompressed binary files
    node ./lzss.js decode -v -o "${encoded_offset}" "$rom_path" "${decoded_path}"
    node ./lzss.js encode -v "${decoded_path}" "${encoded_path}"
  else
    # Generate fresh compressed files only
    node ./lzss.js encode -v -o "${decoded_offset}" "$rom_path" "${encoded_path}"
  fi
}


###########################################
### * Define compressed sections here * ###
###########################################

handle "intro" "0xC2686C" "0xF00000"

