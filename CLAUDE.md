# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Applying changes

```bash
# Rebuild and switch to the new configuration
sudo nixos-rebuild switch --flake /etc/nixos#nixos

# Test a build without activating (dry run)
sudo nixos-rebuild dry-build --flake /etc/nixos#nixos

# Enter the dev shell (provides nil, alejandra, git)
nix develop /etc/nixos
```

## Formatting

```bash
# Format all Nix files
alejandra .

# Check formatting without writing
alejandra --check .
```

## Architecture

This is a NixOS Flakes configuration for the machine "McBoxGyver" — a Mac (iMac 2014 hardware) running NixOS on `x86_64-linux`, targeting `nixpkgs/nixos-25.11`.

### Module layout

| File | Purpose |
|---|---|
| [flake.nix](flake.nix) | Entry point. Declares inputs (`nixpkgs`, `nix-claude-code`), wires all modules into `nixosConfigurations."nixos"`, and defines a `devShell` with `nil + alejandra + git`. |
| [configuration.nix](configuration.nix) | Core system: bootloader, kernel, networking, display (KDE Plasma 6 / SDDM), PipeWire audio, keyd keyboard remapping, hid_apple tuning, cedilha XCompose fix, HDD sysctl optimization, user account. |
| [arsenal.nix](arsenal.nix) | All system packages: browsers, editors (`vscodium-fhs`, `micro`), `nix-claude-code`, Python stack (Jupyter, pandas, numpy, langchain, chromadb), and two custom scripts (`portal-puredhamma`, `syncsong`). |
| [vertex-ai.nix](vertex-ai.nix) | AI infrastructure via Podman: LiteLLM proxy (port 4000) routing to Vertex AI Gemini, and OpenWebUI (port 3000). GCP key lives at `/var/secrets/gcp-key.json`. |
| [hardware-configuration.nix](hardware-configuration.nix) | Auto-generated — do not edit manually. |

### Double-import of arsenal.nix

`arsenal.nix` is listed both in `flake.nix`'s `modules` list **and** in `configuration.nix`'s `imports`. NixOS deduplicates modules, so this is harmless but redundant. If restructuring, pick one location.

### Key customizations

- **Keyboard (keyd):** `leftshift` = `overload(shift, tab)` (tap for Tab, hold for Shift); `rightmeta` (physical Option key next to arrows) activates `nav_layer` (arrows → Home/End/PgUp/PgDn/Delete).
- **hid_apple:** `fnmode=2` (F-keys default to F1–F12), `swap_opt_cmd=1` (swaps Command and Option physically).
- **Audio:** PipeWire only — `pulseaudio.enable = false`.
- **Cedilha fix:** Custom `/etc/X11/XCompose` applied globally via `XCOMPOSEFILE` env var.
- **nix-ld:** Enabled to run foreign ELF binaries without patching.

### ARCHEOLOGY/

Historical snapshots of config files for archaeology/reference. Not active configuration — do not import or rely on it.
