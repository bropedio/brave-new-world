# BNW v3.0 Reference Documentation

This document provides a comprehensive breakdown of all patches included in BNW v3.0. Each section corresponds to a specific patch and includes technical documentation, rationale, and implementation details as needed.

----------------------------------------------------------------------------

## Table of Contents

The following patches are in insertion order:

- Versioning (3.0.0)
- Title Screen Overhaul
- Figaro Guard Fix (Sabin's flashback)
- Drained Pool Tile (Serpent Trench)
- Castle Party (Sabin/Shadow/Cyan switches)
- Blush Disease (Setzer/Celes "Wife" blushing)
- Tube Job (Magitek Factory background glitch)
- Bridge Correction (Sealed Gate battle background)
- Phantom Train Chests (Invisible chest fix)
- Solar Wind (Quasar glitch fix)
- More Walkable Beach (Fish-catching QOL)
- Cafe to Pub (Uncensor pub signs)
- Eddie Background (Kefka battle special background)

----------------------------------------------------------------------------

## Versioning

**Status:** Merged
**Files:** `reference/v3.0/version.asm`

### Why

The player should be able to identify the current hack version they are playing.

### Details

- Write the hack name and version to the Config menu (3.0.0)

----------------------------------------------------------------------------

## Title Screen Overhaul

**Author:** ???
**Status:** Merged
**Files:**
- `ips/04-cinematic-program.ips`,
- `ips/05-title-isle-gfx.ips`

### Why

The japanese title screen is canon

### Details

- Completely replace the entire compressed data block at $C2686C
- Completely replace huge swaths of $D8/$D9 compressed graphics
- Requires update to RNG tweaks in `asm/compressed/title.asm`

----------------------------------------------------------------------------

## Figaro Guard Fix

**Author:** DrakeyC
**Status:** Unmerged
**Files:** `reference/v3.0/figaro-guard-fix.asm`

### Why

There is an oversight with four guards in Figaro Castle (two by the doors to the wings of the castle, and two by the doors to the throne room). In the event for Sabin’s flashback to when he left the castle, an event bit is cleared to remove these guards for the scene where he and Edgar are outside the castle, but this bit is never re-set. So, if Sabin’s flashback is viewed at any time, all four of these guards vanish and never reappear.

### Details

- Add a small jump to the flashback event to reset the event bit and cause the guards to reappear.
- Cannibalize some presumably unused Shadow dialogue event code.

----------------------------------------------------------------------------

## Drained Pool Tile

**Author:** Gi Nattak
**Status:** Unmerged
**Files:** `reference/v3.0/drained-pool-tile.asm`

### Why

There is a buggy map tile after the pool of water is drained from the Serpent Trench cave and the menu is opened and closed.

### Details

- Modify relevant event scripts
- Add new subroutine in $E6 freespace

----------------------------------------------------------------------------

## Castle Party

**Author:** Leet Sketcher
**Status:** Unmerged
**Files:** `reference/v3.0/castle-party.asm`

### Why

During the scene where Sabin infiltrates the Imperial Camp near Doma Castle, the game repeatedly switches back and forth between him in the camp and Cyan in Doma. As the game switches back from Cyan to Sabin, sometimes the game changes the order of the members of Sabin's party. This is annoying, especially if Shadow is in Sabin's party.

### Details

- We no longer "assign character to party 1" or "remove from party". We now explicitly switch parties instead.

----------------------------------------------------------------------------

## Blush Disease

**Author:** Novalia Spirit
**Status:** Unmerged
**Files:** `reference/v3.0/blush-disease.asm`

### Why

During the scene where Setzer askes Celes to be his wife, she blushes. But due a bug, if Edgar is in the party, then he and Sabin (if present) will also blush.

### Details

- Replace incomplete checks for Sabin's presence with code that swaps Celes's palette with the background palette, then applies the blush effect to *that* palette instead.

----------------------------------------------------------------------------

## Tube Job

**Author:** Gi Nattak
**Status:** Unmerged
**Files:**
- `reference/v3.0/tube-job.asm`
- `reference/v3.0/tube-job.bin`

### Why

The large glass tubes inside the Magitek Factory Laboratory have an issue with two of the background layer 3 tiles: An incorrect palette of $00 being assigned instead of $0C like the rest of the tube's tiles. Palette $00 is reserved for the font color, so whatever color the font is set to, two tiles at the top-right and top-left of
the tube would show this same color.

### Details

- Modify compressed graphics data to update the palette used by the buggy background tiles.
- Overwrite a significant amount of data: $E6C300-$E6C603

----------------------------------------------------------------------------

## Bridge Correction

**Author:** Gi Nattak
**Status:** Unmerged
**Files:**
- `reference/v3.0/bridge-correction.asm`
- `reference/v3.0/bridge-correction.bin`

### Why

There are two small, rather hard to notice graphical issues with the Sealed Gate battle background.

### Details

- Update battle background data to fix the buggy bridge tile palettes.
- Overwrite large data block from $E8B2C7-$E8B8B0, plus a few other bytes

----------------------------------------------------------------------------

## Phantom Train Chests

**Author:** Dark Mage [?]
**Status:** Unmerged
**Files:**
- `reference/v3.0/phantom-train-chests.asm`
- `reference/v3.0/phantom-train-chests-1.bin`
- `reference/v3.0/phantom-train-chests-2.bin`
- `reference/v3.0/phantom-train-chests-3.bin`

### Why

There are two treasure chests on the Phantom (Soul) Train that are invisible.

### Details

- Set contents of one chest to 1000 GP
- Update some event code related to WoR Phantom Train [?]
- Overwrite enormous amount of map formation data. See asm for ranges

----------------------------------------------------------------------------

## Solar Wind

**Author:** Leet Sketcher
**Status:** Unmerged
**Files:**
- `reference/v3.0/solar-wind.asm`
- `reference/v3.0/solar-wind.bin`

### Why

The Lore Quasar has a glitch wherein if you cast it before using either W Wind or Spiraler, the tornado will be messed up and come out looking like a wavy stripe pattern.

### Details

- Tweak FlareStar animation to make some extra room
- Fix the Quasar animation script to ensure HDMA scroll data is cleared
- Update pointers to affected script locations

----------------------------------------------------------------------------

## More Walkable Beach

**Author:** Fëanor
**Status:** Unmerged
**Files:**
- `reference/v3.0/more-walkable-beach.asm`
- `reference/v3.0/more-walkable-beach.bin`

### Why

The fish catching sequence on Solitary Island is needlessly time consuming. Limited walkable beach tiles make catching fish annoying.

### Details

- Update map tile properties to allow walking on more beach tiles
- Update pointers to affected property data blocks

----------------------------------------------------------------------------

## Cafe to Pub

**Author:** Gens
**Status:** Unmerged
**Files:** `reference/v3.0/cafe-to-pub.asm`

### Why

The US localization censored "PUB" signs to "CAFE".

### Details

- Modify tile data for 4 total CAFE signs in map graphics
- Update one small palette word (unknown reasons)

----------------------------------------------------------------------------

## Eddie Background

**Author:** Gens
**Status:** Unmerged
**Files:**
- `reference/v3.0/eddie-bg.asm`
- `reference/v3.0/eddie-bg-tile-pointers.asm`
- `reference/v3.0/eddie-bg-tile-formations.asm`
- `reference/v3.0/eddie-bg-gfx-1.asm`
- `reference/v3.0/eddie-bg-gfx-2.asm`

### Why

Final Kefka battle in BNW needs a little something...special.

### Details

- Modifies huge amount of data, including:
  - Field sprite graphics
  - Character color palettes
  - Pointers to battle bg tile formations
  - Battle bg tile formations
  - Battle bg graphics


