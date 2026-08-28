const fs = require('fs');

const settings = require('../settings.json');

const { applyAllPatches } = require('./patch.cjs');
const { assembleAll } = require('./assemble.cjs');
const { updateChecksum } = require('./checksum.cjs');
const { createPatches } = require('./create_patches.cjs');
const { convertAllPatches } = require('./convert_patches.cjs');

const command = process.argv[2];
const args = process.argv.slice(3);

const commands = {
  build: async () => {
    const [rom_path, version] = args;
    if (!rom_path || !version) {
      console.error('Usage: npm run build -- <rom_path> <version>');
      process.exit(1);
    }
    fs.copyFileSync(settings.ff6_path, rom_path);
    applyAllPatches(rom_path);
    assembleAll(rom_path, rom_path + '.sym');
    updateChecksum(rom_path);
    await createPatches(rom_path, version);
  },
  patch: () => {
    const [rom_path] = args;
    if (!rom_path) {
      console.error('Usage: node scripts/run.cjs patch <rom_path>');
      process.exit(1);
    }
    applyAllPatches(rom_path);
  },
  assemble: () => {
    const [rom_path] = args;
    if (!rom_path) {
      console.error('Usage: node scripts/run.cjs assemble <rom_path>');
      process.exit(1);
    }
    assembleAll(rom_path);
  },
  checksum: () => {
    const [rom_path] = args;
    if (!rom_path) {
      console.error('Usage: node scripts/run.cjs checksum <rom_path>');
      process.exit(1);
    }
    updateChecksum(rom_path);
  },
  convert: () => {
    convertAllPatches();
  },
  help: () => {
    console.log('Available commands:');
    console.log('  build <rom_path> <version> - Run the full build pipeline');
    console.log('  patch <rom_path>           - Apply all IPS patches');
    console.log('  assemble <rom_path>        - Assemble all ASM files');
    console.log('  checksum <rom_path>        - Calculate and fix ROM checksum');
    console.log('  convert                    - Convert h-ips patches to standard format');
    console.log('  help                       - Show this menu');
  }
};

if (!command || !commands[command]) {
  console.log(`Unknown command: ${command}`);
  commands.help();
  process.exit(1);
}

commands[command]().catch(err => {
  console.error(err);
  process.exit(1);
});
