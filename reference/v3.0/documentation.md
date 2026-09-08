# BNW v3.0 Reference Documentation

This document provides a comprehensive breakdown of all patches included in BNW v3.0. Each section corresponds to a specific patch and includes technical documentation, rationale, and implementation details as needed.

----------------------------------------------------------------------------

## Table of Contents

The following patches are in insertion order:

- Versioning

----------------------------------------------------------------------------

## Versioning

**Files:** `reference/v3.0/version.asm`
**Status:** Unmerged

### Why

The player should be able to identify the current hack version they are playing.

### Details

- Writes the hack name and version to the Config menu.

----------------------------------------------------------------------------

## Title Screen Overhaul

**Files:**
- `ips/04-cinematic-program.ips`,
- `ips/05-title-isle-gfx.ips`

**Status:** Merged

### Why

The japanese title screen is canon

### Details

- Completely replaces the entire compressed data block at $C2686C
- Completely replaces huge swaths of $D8/$D9 compressed graphics
- Requires update to `asm/compressed/title.asm`

----------------------------------------------------------------------------
