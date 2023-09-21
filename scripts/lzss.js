"use strict";

const fs = require('fs');
const path = require('path');
const { parseArgs } = require('util');

const { positionals: args, values: options } = parseArgs({
  allowPositionals: true,
  options: {
    offset: { type: 'string', short: 'o' },
    verbose: { type: 'boolean', short: 'v' }
  }
});

const [
  action,
  input_path,
  output_path=String(Date.now())
] = args;

options.offset = options.offset && (parseInt(options.offset, 16) - 0xC00000);

main(action, input_path, output_path, options);

function main (action, input_path, output_path, options) {
  const input_buffer = fs.readFileSync(input_path);
  
  const func = {
    encode: compress,
    decode: decompress,
    compress,
    decompress
  }[action];
  
  if (!func) {
    throw new Error(`Action ${action} not supported`);
  }
  
  const result = func(input_buffer, options);
  const safe_path = path.resolve(process.cwd(), output_path);
  fs.writeFileSync(output_path, result);
}

function decompress (ff6, opts) {
  let offset = opts.offset || 0;
  const length = ff6.readUint16LE(offset);
  const end_offset = offset + length;
  offset += 2;

  const dictionary = new Uint8Array(0x800);
  const data = [];

  function add_data (value) {
    const dictionary_index = (data.length + 0x7DE) & 0x7FF;
    dictionary[dictionary_index] = value;
    data.push(value);
  }

  let control, counter;

  while (offset < end_offset) {
    if (!counter) {
      control = ff6.readUint8(offset);
      offset++;
      counter = 8;
      continue;
    }

    if (control & 0x01) {
      add_data(ff6.readUint8(offset));
      offset++;
    } else {
      let info = ff6.readUint16LE(offset);
      offset += 2;
      let match_index = info & 0x7FF;
      let match_length = (info >>> 11) + 3;

      while (match_length--) {
        add_data(dictionary[match_index & 0x7FF]);
        match_index++;
      }
    }

    control >>>= 1;
    counter--;
  }

  return Buffer.from(data);
}

function compress (full_source_data, opts) {
  const offset = opts.offset || 0;
  const source_length = full_source_data.readUint16LE(offset);
  const source_data = full_source_data.subarray(offset + 2, offset + 2 + source_length);
  const buffer_size = 0x800;
  const dictionary_length = buffer_size + source_length;
  const min_length = 3;
  const max_length = 34;
  const buffer_offset = buffer_size - max_length;

  const compressed = [0, 0];
  const dictionary = new Uint8Array(dictionary_length);
  dictionary.set(source_data, buffer_size);

  let index = buffer_size;
  let control_offset, control, bitmask;

  refresh_control(); 

  function refresh_control () {
    control_offset = compressed.length;
    compressed.push(control);
    control = 0x00;
    bitmask = 0x01;
  }

  function write_control () {
    compressed[control_offset] = control;
  }

  function next_bit (on) {
    if (on) {
      control |= bitmask;
    }

    if (bitmask === 0x80) {
      write_control();
      refresh_control();
    } else {
      bitmask <<= 1;
    }
  }

  while (index < dictionary.length) {
    let best_match_length = min_length - 1;
    let best_match_index = null;
    let max_match = Math.min(max_length, dictionary.length - index);

    // We loop through 0x800, instead of buffer offset, which improves
    // compression somewhat. It appears that FF6 compression limited to
    // 0x7DE under the assumption that a max-length (34) chunk might
    // overflow into 0x800, which is outside the bounds of the dictionary.
    // But since the native decompression algorithm in C2 handles wrapping
    // the dictionary offset, this limitation is not necessary.
    for (let source = index - 0x800; source < index; ++source) {
      let match_length = 0;

      while (match_length < max_match) {
        const source_byte = dictionary[index + match_length];
        const match_byte = dictionary[source + match_length];
        if (source_byte !== match_byte) break;

        match_length++;
      }

      if (match_length > best_match_length) {
        best_match_length = match_length;
        best_match_index = source;
      }
    }

    if (best_match_index != null) {
      const stored_length = best_match_length - min_length;
      const real_match_index = (best_match_index + buffer_offset) & 0x7FF;
      const info = (stored_length << 11) | real_match_index;
      compressed.push(info & 0xFF, info >> 8);
      index += best_match_length;
      next_bit(false);
    } else {
      compressed.push(dictionary[index]);
      index += 1;
      next_bit(true);
    }
  }

  // Clean up partial control byte
  if (bitmask === 0x01) {
    // Empty control, overwrite it
    compressed.pop();
  } else {
    // Write partial control byte
    write_control();
  }

  if (opts.verbose) {
    console.log(`LZSS Compression: ${source_data.length} => ${compressed.length}`);
  }

  compressed[0] = compressed.length & 0xFF;
  compressed[1] = compressed.length >> 8;

  return Buffer.from(compressed);
}
