module.exports = {
  compressed_entries: [{
    file: "title.asm",
    offset: 0xC2686C,
    warn: 0xC28A60
  }, {
    file: 'wob-tilemap.asm',
    offset: 0xEED434,
    warn: 0xEF1000
  }, {
    file: 'wob-tile-gfx.asm',
    source: 0xEF114F, // Source data read from here
    offset: 0xEF1000, // Modified block written here
    warn: 0xEF3250
  }]
};
