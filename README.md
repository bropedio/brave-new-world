# Brave New World
#### The Final Fantasy 6 ROM Hack by BTB and Synchysi

This is the official repo for development of the Brave New World ROM Hack (BNW).

*While it is possible to build BNW using this repository, please note that some
"hidden" features (e.g. the Mystery Egg) are not available here, so any builds
will be incomplete*

* The `master` branch will always contain the most recent stable version of BNW
* The `develop` branch will always contain the current base for new feature development


## How to Build

1. Install `node` version 24.0.0 or later
2. Run `npm run init -- path/to/your/ff6/rom` to generate `settings.json` in the root directory
3. Execute the following in your terminal:

```
npm run build -- <path/to/output/rom> <version_name>
```

The built ROM can be found at the path you specified, and the newly generated IPS patches will be inside the `/releases` directory

## Structure of the Repo

* `README.md` - You're reading it right now
* `CHANGELOG.md` - Brief descriptions of each feature/hack, organized by version
* `documentation.md` - Comprehensive descriptions of all BNW feature hacks
* `settings.json` - Configuration file containing paths to your ROM and build tools
* `scripts/` - Node.js scripts for building the ROM and IPS patches
* `tools/` - Pre-compiled binaries for cross-platform compatibility
* `ips/` - IPS patches that are applied in the first step of the build process
* `asm/banks/` - One `.asm` file for each modified FF6 bank, applied in the second step of the build
* `asm/private/` - Empty directory where "hidden" patches must be added prior to official BNW builds
* `asm/optional/` - Optional patches
* `reference/` - Development artifacts and patches that have been integrated into the `banks` asm files

## How to Contribute

Contributions are welcome, and will be reviewed and merged on a per-feature
basis.

1. Fork the `brave-new-world` repo
2. Create a new branch named after your feature, based on the `develop` branch
3. Add your complete `.asm` into `reference/{version}/`
4. Fully integrate your `.asm` into the `asm/banks/` files
   * Please keep all `org` statements ordered by address
   * Use `; ---` and `; ###` line breaks to organize sections of code
   * Comment liberally, especially when altering existing code
5. Open a pull request against `brave-new-world/develop` with a comprehensive
   description that describes the "what," "why," and "how" of the changes.

Accepted features will be squashed into a single commit when merging.

## Beta Testing

Each release candidate is tracked in a unique testing branch (eg. `v2.2.0-beta-18`).
If you would like to help test the current beta version, ask for the Beta Tester
role at our Discord (via ngplus.net).
