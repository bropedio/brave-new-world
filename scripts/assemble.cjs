const fs = require('fs');
const path = require('path');

const { asar } = require('./tools.cjs');
const { generateSymbolMap, processCompressedBlocks } = require('./compressed.cjs');

function assemble (asm_file, target_rom, opts={}) {
  asar.assemble(asm_file, target_rom, {
    ...opts,
    mute_deprecation_warnings: true
  });
}

function getAsmFiles (category) {
  const category_dir = path.join(process.cwd(), 'asm', category);
  const dir_files = fs.readdirSync(category_dir);

  return (dir_files
    .filter(file => file.endsWith('.asm'))
    .map(file => path.join(category_dir, file))
  );
}

function assembleBatch (category, target_rom) {
  for (const asm_file of getAsmFiles(category)) {
    assemble(asm_file, target_rom);
  }
}

function assembleAll (target_rom, version=Date.now()) {
  // Assemble asm by bank
  process.stdout.write('Assembling asm/banks...');
  const bank_files = getAsmFiles('banks');
  const all_banks_content = bank_files.map(
    file => fs.readFileSync(file) // TODO: promisify async
  ).join('\n');

  const all_banks_path = path.join(process.cwd(), 'asm', 'banks', '_all_banks.asm');
  const symbol_map_path = path.join(process.cwd(), 'asm', 'banks', '_symbols.sym');
  const symbol_asm_rel = path.join('asm', 'symbols.autogen.asm');
  const symbol_asm_path = path.join(process.cwd(), symbol_asm_rel);

  fs.writeFileSync(all_banks_path, all_banks_content);
  try {
    assemble(all_banks_path, target_rom, { symbol_map_path });
  } finally {
    fs.rmSync(all_banks_path);
  }
  console.log('done');

  // Generate symbols for compressed
  process.stdout.write(`Generating symbol map at ${symbol_asm_rel}...`);
  generateSymbolMap(version, symbol_map_path, symbol_asm_path);
  fs.rmSync(symbol_map_path);
  console.log('done');

  // Assemble private assembly
  process.stdout.write('Assembling asm/private...');
  assembleBatch('private', target_rom);
  console.log('done');

  // Assemble compressed
  process.stdout.write('Assembling asm/compressed...');
  processCompressedBlocks(target_rom);
  console.log('done');
}

module.exports = {
  assembleAll
};
