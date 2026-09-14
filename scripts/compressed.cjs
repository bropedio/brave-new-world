const fs = require('fs');
const path = require('path');
const lzss = require('./lzss.cjs');
const { asar } = require('./tools.cjs');
const { compressed_entries } = require('../asm/compressed/map.cjs');

function generateSymbolMap (version, sym_path, sym_asm_path) {
  const symContent = fs.readFileSync(sym_path, 'utf8');
  const lines = symContent.split('\n');
  const output = [
    `; Auto-generated symbol map - DO NOT MODIFY`,
    `; Date: ${new Date().toISOString()}`,
    `; Build: ${version}`,
    ''
  ];

  for (const line of lines) {
    // Expected format: 00C16872 ATBDrawFix
    const match = line.match(/^([0-9A-Fa-f]{8})\s+([^:]*)$/);
    if (match) {
      const address = match[1];
      const symbol = match[2];
      output.push(`${symbol} = $${address.substring(2)}`);
    }
  }

  fs.writeFileSync(sym_asm_path, output.join('\n'));
}

function processCompressedBlocks (rom_path) {
  const tempDir = path.join(process.cwd(), 'asm', 'compressed', 'temp');
  if (!fs.existsSync(tempDir)) fs.mkdirSync(tempDir);

  const rom_buffer = fs.readFileSync(rom_path);
  const src_buffer = Buffer.from(rom_buffer); // clone

  for (const { file, source, offset, warn } of compressed_entries) {
    if (!Number.isInteger(warn)) {
      throw new Error(`Missing warn boundary for ${file}`);
    }
    if (!Number.isInteger(offset)) {
      throw new Error(`Missing offset for ${file}`);
    }

    const source_index = (source ?? offset) - 0xC00000;
    const target_index = offset - 0xC00000;
    const max_length = warn - offset;

    const asm_file = path.join(process.cwd(), 'asm', 'compressed', file);

    // Decompress
    const temp_bin = path.join(tempDir, path.basename(file, '.asm') + '.temp.bin');
    const decompressed = lzss.decompress(src_buffer, { offset: source_index });
    fs.writeFileSync(temp_bin, decompressed);

    // Assemble (Asar will modify temp_bin in-place because we pass it as the target)
    // We assume the asm file uses 'norom'
    asar.assemble(asm_file, temp_bin, {
      mute_deprecation_warnings: true,
      norom: true
    });

    // Recompress
    const assembled = fs.readFileSync(temp_bin);
    const recompressed = lzss.compress(assembled);

    // Check boundary
    if (recompressed.length > max_length) {
      throw new Error(`Compressed code overflowed boundary at ${file}!`);
    }

    // Write back to ROM
    rom_buffer.set(recompressed, target_index);
  }

  fs.writeFileSync(rom_path, rom_buffer);

  // Cleanup
  fs.rmSync(tempDir, { recursive: true, force: true });
}

module.exports = { generateSymbolMap, processCompressedBlocks };
