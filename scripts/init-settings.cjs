const fs = require('fs');
const path = require('path');
const os = require('os');

// 1. Get the ROM path argument
const romPath = process.argv[2];

if (!romPath) {
  console.error('\x1b[31mError:\x1b[0m Please provide a path to your FF6 ROM.');
  console.error('\nUsage:\n  npm run init -- <path-to-rom>\n');
  console.error('Example:\n  npm run init -- roms/ff3-1.1-n.sfc');
  process.exit(1);
}

// 2. Validate ROM existence
const resolvedRomPath = path.resolve(romPath);

if (!fs.existsSync(resolvedRomPath)) {
  console.error(`\x1b[31mError:\x1b[0m ROM file not found at "${resolvedRomPath}"`);
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
    win32:  'win-x64', // Windows ARM64 handles win-x64 via native emulation
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
const asarBin = getTool('asar', platform);
const ipsBin = getTool('flips', platform);

// 4. Construct content for ./scripts/settings.sh
const settingsContent = `#!/bin/bash

# To update this settings file, run "npm run init" from the project root.
# Or, you can manually set your ROM and tool binary paths below.

SCRIPT_DIR="$(cd "$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ASAR_PATH="$PROJECT_ROOT/${asarBin}"
IPS_PATH="$PROJECT_ROOT/${ipsBin}"
FF6_PATH="$PROJECT_ROOT/${romPath}"
`;

// 5. Ensure scripts directory exists and write output
const targetDir = path.join(__dirname);
if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}
const targetPath = path.join(targetDir, 'settings.sh');
fs.writeFileSync(targetPath, settingsContent, { mode: 0o755 });

console.log(`\x1b[32mSuccessfully generated ${targetPath}\x1b[0m`);
console.log(`- ASAR_PATH="${asarBin}"`);
console.log(`- IPS_PATH="${ipsBin}"`);
console.log(`- FF6_PATH="${romPath}"`);
