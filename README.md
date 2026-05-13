# Omnivium

Standalone Neovim configuration — independent from introdus, built with nix-wrapper-modules and flake-parts.

## Architecture

- **Nix wrapper**: Uses [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) for the wrapper-based Neovim packaging architecture
- **flake-parts**: Mandatory integration via `flake-parts.lib.mkFlake`
- **Plugin management**: Nix `specs` for declarative plugin declarations, `lze`/`lzextras` for lazy loading in Lua
- **Lua namespace**: `omnivium`

## Quick Start

```bash
# Build basic (no dev plugins)
nix build .#basic

# Build full (devMode, neovide, terminalMode)
nix build .#full

# Run
./result/bin/nvim
```

## Module System

The Nix module `module.nix` defines:
- `options.settings.*` — devMode, terminalMode, neovide, guifont
- `config.specs.*` — plugin categories (core always enabled, others commented out)
- `config.specMods` — extraPackages/mainInfo per spec

See `module.nix` for all available spec categories (commented out).

## Adding Plugins

1. Uncomment the spec in `module.nix`
2. Create `lua/omnivium/<category>/<plugin>.lua`
3. Add the lze.load entry in `init.lua`

## Flake Outputs

- `packages.neovim` — default package
- `packages.basic` — stable build without hot-reload
- `packages.full` — dev build with hot-reload and all features