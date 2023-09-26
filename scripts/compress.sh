#!/bin/bash

rom_path="$1"
bin="../asm/banks/bin"

node ./lzss.js encode "$rom_path" "${bin}/title-compressed.bin" -v -o 0xF00000
