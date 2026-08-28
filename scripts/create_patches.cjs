const fs = require('fs');
const path = require('path');
const { zipSync } = require('fflate');

const { flips } = require('./tools.cjs');
const settings = require('../settings.json');

function createPatch (original, patched, output) {
  flips.create(original, patched, output);
}

function createPatches (bnw_path, version) {
  return new Promise((resolve, reject) => {
    const tmp_dir = path.join(process.cwd(), 'tmp');
    const bnw_h_path = path.join(tmp_dir, 'bnw-h.sfc');
    const ff6_h_path = path.join(tmp_dir, 'ff6-h.sfc');
    const n_ips_path = path.join(tmp_dir, `[n]BNW-${version}.ips`);
    const h_ips_path = path.join(tmp_dir, `[h]BNW-${version}.ips`);
    const zip_path = path.join(process.cwd(), 'releases', `BNW-${version}.zip`);

    if (fs.existsSync(tmp_dir)) {
      fs.rmSync(tmp_dir, { recursive: true });
    }
    fs.mkdirSync(tmp_dir);

    const header = Buffer.alloc(512, 0);

    function writeHeadered (source, target) {
      const sourceData = fs.readFileSync(source);
      const combined = Buffer.concat([header, sourceData]);
      fs.writeFileSync(target, combined);
    }

    writeHeadered(bnw_path, bnw_h_path);
    writeHeadered(settings.ff6_path, ff6_h_path);

    process.stdout.write('Creating IPS patches...');
    createPatch(settings.ff6_path, bnw_path, n_ips_path);
    createPatch(ff6_h_path, bnw_h_path, h_ips_path);
    console.log('done');

    process.stdout.write('Zipping patches for release...');
    const n_ips_data = fs.readFileSync(n_ips_path);
    const h_ips_data = fs.readFileSync(h_ips_path);
    const zipData = zipSync({
      [path.basename(n_ips_path)]: n_ips_data,
      [path.basename(h_ips_path)]: h_ips_data
    });
    fs.writeFileSync(zip_path, Buffer.from(zipData));
    fs.rmSync(tmp_dir, { recursive: true });
    console.log('done');
    resolve();
  });
}

module.exports = {
  createPatches
};
