const fs = require('fs');
const path = require('path');
const os = require('os');

// 1. Get the ROM path argument
const rom_path = process.argv[2];

if (!rom_path) {
  console.error('\x1b[31mError:\x1b[0m Please provide a path to your FF6 ROM.');
  console.error('\nUsage:\n  npm run init -- <path-to-rom>\n');
  console.error('Example:\n  npm run init -- roms/ff3-1.1-n.sfc');
  process.exit(1);
}

// 2. Validate ROM existence
const resolved_rom_path = path.resolve(rom_path);

if (!fs.existsSync(resolved_rom_path)) {
  console.error(`\x1b[31mError:\x1b[0m ROM file not found at "${resolved_rom_path}"`);
  process.exit(1);
}

// 3. Construct content for ./settings.json
const settings_content = {
  asar_path: null,
  ips_path: null,
  ff6_path: resolved_rom_path
};

// 4. Ensure scripts directory exists and write output
const target_path = path.join(__dirname, '..', 'settings.json');
fs.writeFileSync(target_path, JSON.stringify(settings_content, null, 2));

console.log(`\x1b[32mSuccessfully generated ${target_path}\x1b[0m`);
console.log(`- ASAR_PATH=null (will auto-detect)`);
console.log(`- IPS_PATH=null (will auto-detect)`);
console.log(`- FF6_PATH="${settings_content.ff6_path}"`);

