const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const archiver = require('archiver');

const settings = require('./settings.json');

function createPatch (original, patched, output) {
  execFileSync(
    settings.ips_path,
    ['--create', '--ips', original, patched, output],
    { stdio: 'ignore' }
  );
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
    const output = fs.createWriteStream(zip_path);
    const archive = archiver('zip', { zlib: { level: 9 } });

    archive.pipe(output);
    archive.file(n_ips_path, { name: path.basename(n_ips_path) });
    archive.file(h_ips_path, { name: path.basename(h_ips_path) });
    archive.finalize();

    output.on('close', () => {
      fs.rmSync(tmp_dir, { recursive: true });
      console.log('done');
      resolve();
    });

    output.on('error', reject);
  });
}

module.exports = {
  createPatches
};
