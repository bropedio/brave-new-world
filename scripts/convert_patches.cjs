const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const settings = require('./settings.json');

/**
 * ORIGINAL BASH:
 * apply_patch () {
 *   "$IPS_PATH" --apply "$1" "$BASE_FF6_H" "$PATCHED_H"
 * }
 * create_patch () {
 *   "$IPS_PATH" --create --ips "$BASE_FF6_N" "$PATCHED_N" "$1"
 * }
 */

function applyPatch (ips_file, base_ff6_h, patched_h) {
  execFileSync(settings.ips_path, ['--apply', ips_file, base_ff6_h, patched_h], {
    stdio: 'ignore'
  });
}

function createPatch (output_file, base_ff6_n, patched_n) {
  execFileSync(settings.ips_path, ['--create', '--ips', base_ff6_n, patched_n, output_file], {
    stdio: 'ignore'
  });
}

function convertAllPatches () {
  const base_ff6_n = path.join(process.cwd(), 'roms', 'ff3-1.1-n.sfc');
  const base_ff6_h = path.join(process.cwd(), 'roms', 'ff3-1.1-h.sfc');
  const patched_h = path.join(process.cwd(), 'roms', 'temp-patched-h.sfc');
  const patched_n = path.join(process.cwd(), 'roms', 'temp-patched-n.sfc');

  const h_ips_dir = path.join(process.cwd(), 'h-ips');
  const ips_files = fs.readdirSync(h_ips_dir).filter(file => file.endsWith('.ips'));

  for (const file of ips_files) {
    const ips_file = path.join(h_ips_dir, file);
    applyPatch(ips_file, base_ff6_h, patched_h);
    
    // tail -b +2 means skip 512 bytes
    const patched_h_buffer = fs.readFileSync(patched_h);
    fs.writeFileSync(patched_n, patched_h_buffer.subarray(512));
    
    const output_path = path.join(process.cwd(), 'ips', file);
    createPatch(output_path, base_ff6_n, patched_n);
    
    fs.unlinkSync(patched_h);
    fs.unlinkSync(patched_n);
  }
}

module.exports = {
  convertAllPatches
};
