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

// 3. Detect Platform & Map Tool Executables
const tools = {
  asar: {
    'win-x64': 'tools/asar-1.91/win-x64/asar.exe',
    'mac-arm64': 'tools/asar-1.91/mac-arm64/asar',
    'linux-x64': 'tools/asar-1.91/linux-x64/asar',
  },
  flips: {
    'win-x64': 'tools/flips-198/win-x64/flips.exe',
    'mac-arm64': 'tools/flips-198/mac-arm64/flips',
    'linux-x64': 'tools/flips-198/linux-x64/flips',
  }
};

function getBinaryFolder () {
  const platform = os.platform();
  const arch = os.arch();
  return {
    win32:  'win-x64',
    darwin: arch === 'arm64' ? 'mac-arm64' : 'mac-x64',
    linux:  arch === 'arm64' ? 'linux-arm64' : 'linux-x64'
  }[platform];
}

function getTool (tool, platform) {
  try {
    return tools[tool][platform] || tool;
  } catch {
    console.error(`\x1b[31mError:\x1b[0m Unsupported operating system: ${platform}`);
    process.exit(1);
  }
}

const platform = getBinaryFolder();
const asar_bin = getTool('asar', platform);
const ips_bin = getTool('flips', platform);

// 4. Construct content for ./scripts/settings.json
const settings_content = {
  asar_path: path.join(__dirname, '..', asar_bin),
  ips_path: path.join(__dirname, '..', ips_bin),
  ff6_path: resolved_rom_path
};

// 5. Ensure scripts directory exists and write output
const target_path = path.join(__dirname, '..', 'settings.json');
fs.writeFileSync(target_path, JSON.stringify(settings_content, null, 2));

console.log(`\x1b[32mSuccessfully generated ${target_path}\x1b[0m`);
console.log(`- ASAR_PATH="${settings_content.asar_path}"`);
console.log(`- IPS_PATH="${settings_content.ips_path}"`);
console.log(`- FF6_PATH="${settings_content.ff6_path}"`);

