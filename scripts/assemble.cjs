const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const settings = require('../settings.json');

function assemble (asm_file, target_rom) {
  execFileSync(
    settings.asar_path,
    ['-wnoWfeature_deprecated', asm_file, target_rom],
    { stdio: 'inherit' }
  );
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

function assembleAll (target_rom) {
  // Assemble asm by bank
  process.stdout.write('Assembling asm/banks...');
  const bank_files = getAsmFiles('banks');
  const all_banks_content = bank_files.map(
    file => fs.readFileSync(file) // TODO: promisify async
  ).join('\n');

  const all_banks_path = path.join(process.cwd(), 'asm', 'banks', '_all_banks.asm');

  fs.writeFileSync(all_banks_path, all_banks_content);
  assemble(all_banks_path, target_rom);
  fs.rmSync(all_banks_path);
  console.log('done');

  // Assemble private assembly
  process.stdout.write('Assembling asm/private...');
  assembleBatch('private', target_rom);
  console.log('done');
}

module.exports = {
  assembleAll
};
