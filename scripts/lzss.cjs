"use strict";

function decompress (ff6, opts={}) {
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

function compress (data) {
  const len = data.length;
  const state_count = (len + 1) * 8;

  // Sliding window dictionary for fast lookup
  const positions = Array.from({ length: 256 }, () => []);
  const heads = new Uint32Array(256);

  for (let i = len - 2, e = len - 0x801; i >= e; i--) {
    // Zero-filled buffer used for dictionary before data
    positions[data[i] || 0].push(i);
  }

  // Dynamic Programming arrays
  const costs = new Float64Array(state_count).fill(Infinity);
  const token_lens = new Uint8Array(state_count);
  const match_idx = new Int32Array(state_count).fill(-0x801);

  // Final EOF cost based on whether Control byte is empty
  for (let s = 0; s < 8; s++) {
    costs[len * 8 + s] = s === 0 ? 0 : 1;
  }

  // Backward pass through each byte
  for (let pos = len - 1; pos >= 0; pos--) {
    const byte = data[pos];
    const candidates = positions[byte];
    const max_length = Math.min(34, len - pos);

    let match_len = 0;
    let match_src = -0x801;

    // Find longest match in sliding dictionary window
    for (let i = heads[byte]; i < candidates.length; i++) {
      const src = candidates[i];
      if (src >= pos) continue;

      let l = 0;
      while (l < max_length && (data[src + l] || 0) === data[pos + l]) {
        l++;
      }

      if (l > match_len) {
        match_len = l;
        match_src = src;

        if (l === max_length) {
          break;
        }
      }
    }

    // Compute cost for each potential control bit position
    for (let slot = 0; slot < 8; slot++) {
      const cur_state = pos * 8 + slot;
      const next_slot = (slot + 1) & 7;
      const ctrl_cost = slot === 7 ? 1 : 0;

      // Tiebreakers
      const consider = (token_cost, token_len, src) => {
        const future_cost = costs[(pos + token_len) * 8 + next_slot];
        const this_cost = token_cost + ctrl_cost + future_cost;

        const best_cost = costs[cur_state];
        const best_len = token_lens[cur_state];
        const best_src = match_idx[cur_state];

        const tiebreak = () => (
          // Only match tokens can win a tie
          token_len > 1 && (
            // Match always beats literal (fewer tokens)
            best_len === 1 ||
            // Longer matches win (fewer cycles)
            token_len > best_len ||
            // More recent sources win (CPU cache)
            (token_len === best_len && src > best_src)
          )
        );

        if (this_cost < best_cost || (this_cost === best_cost && tiebreak())) {
          costs[cur_state] = this_cost;
          token_lens[cur_state] = token_len;
          match_idx[cur_state] = src;
        }
      };

      // Literal byte cost, token length, null source
      consider(1, 1, -0x801);

      if (match_len >= 3) {
        for (let l = 3; l <= match_len; l++) {
          // Match byte cost, token length, source
          consider(2, l, match_src);
        }
      }
    }

    // Keep sliding dictionary window up-to-date
    if (pos > 0) {
      if (candidates[heads[byte]] === pos) {
        heads[byte]++;
      }
      const left_edge = pos - 0x800;
      if (left_edge >= 0) {
        positions[data[left_edge]].push(left_edge);
      } else {
        // Take advantage of zero-filled buffer
        positions[0].push(left_edge);
      }
    }
  }

  // Reconstruction
  const total_size = costs[0] + 2;
  const out = new Uint8Array(total_size);

  let index = 0;
  let pos = 0;

  // Write 16-bit length
  out[index++] = total_size & 0xFF;
  out[index++] = (total_size >> 8) & 0xFF;

  while (pos < len) {
    const control_index = index++;
    let control = 0;

    for (let s = 0; s < 8 && pos < len; s++) {
      const state_index = pos * 8 + s;
      const token_len = token_lens[state_index];
      const source_index = match_idx[state_index];

      if (token_len === 1) { // Literal
        control |= (1 << s);
        out[index++] = data[pos];
      } else { // Match
        const idx = (0x800 + 0x7DE + source_index) & 0x7FF;
        out[index++] = idx & 0xFF;
        out[index++] = ((token_len - 3) << 3) | ((idx >>> 8) & 0x07);
      }
      pos += token_len;
    }

    // Write finalized control byte back to its reserved slot
    out[control_index] = control;
  }

  return out;
}

/**
 * Helpers for use with the perl script available at RomHacking.net
 *

const { execFileSync } = require('child_process');
const perlScriptPath = path.join(process.cwd(), 'lzss.pl');

function compressPerl (input, _opts={}) {
  return execFileSync(
    'perl',
    [perlScriptPath, '-m', 'c', '-'],
    {
      input: input,               // Passes input Buffer directly to STDIN
      encoding: 'buffer',         // Ensures stdout is returned as a raw Buffer
      maxBuffer: 10 * 1024 * 1024 // 10 MB limit
    }
  );
}

function decompressPerl (romBuffer, opts={}) {
  const offset = opts.offset || 0;
  // Slice the buffer starting from the specified offset to the end
  const compressedSlice = romBuffer.subarray(offset);

  return execFileSync(
    'perl',
    [perlScriptPath, '-m', 'd', '-'],
    {
      input: compressedSlice,     // Passes compressed data to STDIN
      encoding: 'buffer',         // Ensures stdout returns as a raw binary Buffer
      maxBuffer: 10 * 1024 * 1024 // 10 MB buffer limit
    }
  );
}
*/

module.exports = {
  compress,
  decompress
};
