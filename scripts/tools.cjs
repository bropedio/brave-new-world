const path = require('path');
const os = require('os');
const { execFileSync } = require('child_process');
const settings = require('../settings.json');

const binaries = {
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

function getToolPath (tool, key) {
  if (settings[key]) {
    return settings[key];
  }

  const platform = getBinaryFolder();
  const binary_path = binaries[tool][platform];

  if (!binary_path) {
    throw new Error(`Unsupported operating system or architecture: ${platform}`);
  }

  return path.join(process.cwd(), binary_path);
}

module.exports = {
  asar: {
    assemble: (asm_file, target_rom, opts={}) => {
      const args = [];
      if (opts.mute_deprecation_warnings) {
        args.push('-wnoWfeature_deprecated');
      }
      if (opts.norom) {
        args.push('--no-title-check');
      }
      if (opts.symbol_map_path) {
        args.push('--symbols=nocash');
        args.push(`--symbols-path=${opts.symbol_map_path}`);
      }
      args.push(asm_file, target_rom);
      execFileSync(getToolPath('asar', 'asar_path'), args, { stdio: 'inherit' });
    }
  },
  flips: {
    apply: (ips_file, target_rom) => {
      execFileSync(
        getToolPath('flips', 'ips_path'),
        ['--apply', ips_file, target_rom, target_rom],
        { stdio: 'ignore' }
      );
    },
    create: (original, patched, output) => {
      execFileSync(
        getToolPath('flips', 'ips_path'),
        ['--create', '--ips', original, patched, output],
        { stdio: 'ignore' }
      );
    }
  }
};
