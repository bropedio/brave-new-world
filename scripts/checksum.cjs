"use strict";

const fs = require('fs');

/* Helpers */
function writeWordAt (buffer, offset, value) {
  buffer[offset] = value & 0xFF;
  buffer[offset + 1] = value >> 8;
}

function updateChecksum (target_rom) {
  const buffer = fs.readFileSync(target_rom);
  let sum = 0;
  let i;

  for (i = 0; i < 0x200000; i++) {
    sum += buffer[i];
  }
  for (i = 0x200000; i < 0x300000; i++) {
    sum += buffer[i] + buffer[i];
  }

  const checksum_val = sum & 0xFFFF;
  const inverted_val = checksum_val ^ 0xFFFF;

  writeWordAt(buffer, 0x00FFDE, checksum_val);
  writeWordAt(buffer, 0x00FFDC, inverted_val);

  fs.writeFileSync(target_rom, buffer);
}

module.exports = {
  updateChecksum
};
