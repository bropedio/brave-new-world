const fs = require('fs');
const path = require('path');

const { flips } = require('./tools.cjs');

function applyPatch (ips_file, target_rom) {
  flips.apply(ips_file, target_rom);
}

function applyAllPatches (target_rom) {
  const ips_dir = path.join(process.cwd(), 'ips');
  const ips_files = fs.readdirSync(ips_dir).filter(
    file => file.endsWith('.ips')
  ).sort();

  process.stdout.write('Applying IPS patches...');

  for (const file of ips_files) {
    if (!/^\d\d-/.test(file)) {
      throw new Error(`IPS Patch "${file}" missing numeric prefix`);
    }
    const ips_file = path.join(ips_dir, file);
    applyPatch(ips_file, target_rom);
  }

  console.log('done');
}

module.exports = {
  applyAllPatches
};
