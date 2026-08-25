const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const settings = require('./settings.json');

function applyPatch (ips_file, target_rom) {
  const output_rom = target_rom;
  execFileSync(
    settings.ips_path,
    ['--apply', ips_file, target_rom, output_rom],
    { stdio: 'ignore' }
  );
}

function applyAllPatches (target_rom) {
  const ips_dir = path.join(process.cwd(), 'ips');
  const ips_files = fs.readdirSync(ips_dir).filter(
    file => file.endsWith('.ips')
  );

  process.stdout.write('Applying IPS patches...');

  for (const file of ips_files) {
    const ips_file = path.join(ips_dir, file);
    applyPatch(ips_file, target_rom);
  }

  console.log('done');
}

module.exports = {
  applyAllPatches
};
