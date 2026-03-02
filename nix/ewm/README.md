# EWM (Emacs Wayland Manager) Nix Packaging

This directory contains Nix packages for EWM, a Wayland compositor that runs inside Emacs as a dynamic module.

## Packages

### ewm-core (default.nix)

The core Rust compositor binary. Builds `libewm_core.so`, a dynamic module that Emacs can load.

**Features:**
- Fetches source from [Codeberg](https://codeberg.org/ezemtsov/ewm)
- Builds with `rustPlatform.buildRustPackage`
- Includes `screencast` feature
- Installs library to `$out/lib/libewm_core.so`
- Provides symlink in `$out/share/emacs/site-lisp/ewm-core.so` for Elisp loading

**Dependencies:**
- **Build:** pkg-config, clang, llvm (for bindgen)
- **Runtime:** libEGL, libwayland-client, libdrm, mesa, libinput, libxkbcommon, seatd, eudev, pipewire, glib

### emacs-ewm (emacs-ewm.nix)

Elisp integration package that provides the module loader and helper functions.

**Features:**
- Simple stdenv.mkDerivation (no build needed for Elisp)
- Installs `.el` files from upstream repo
- Creates symlinks to `ewm-core.so` library for Elisp to find
- Depends on `ewm-core` and `emacs-transient`

## Usage

### Build in Nix

```bash
# Build ewm-core
nix build '.#ewm-core'

# Build emacs-ewm
nix build '.#emacs-ewm'

# Dry-run to see build plan
nix build '.#ewm-core' --dry-run
```

### Integration in flake.nix

The flake includes an `ewm-overlay` that adds both packages to nixpkgs:

```nix
ewm-overlay = final: prev: {
  ewm-core = final.callPackage ./nix/ewm {};
  emacs-ewm = final.callPackage ./nix/ewm/emacs-ewm.nix {};
};
```

### Integration in home.nix

Both packages are included in `home.packages`:

```nix
home.packages = with pkgs; [
  # ... other packages ...
  ewm-core
  emacs-ewm
];
```

Session variables are set to enable EWM:

```nix
home.sessionVariables = {
  XDG_SESSION_TYPE = "wayland";
  XDG_CURRENT_DESKTOP = "ewm";
  EWM_SESSION = "1";
  # ...
};
```

### Launch EWM

**Via environment variable:**
```bash
EWM_SESSION=1 emacs
```

**Via session script:**
```bash
~/.nix-profile/bin/ewm-session
```

The script sets all necessary environment variables and launches Emacs.

## Known Limitations

### cargoHash

The `cargoHash` in `default.nix` is initially set to `null`. When you run `nix build`, Nix will fail with a message showing the expected hash:

```
error: nix-build failed with exit code 1: hash mismatch ...
   expected: sha256-...
   got:      sha256-...
```

Copy the `expected` hash and update `cargoHash` in `default.nix`.

### GPU Passthrough

Ensure `/dev/dri` is accessible in your session:
- If using systemd-nspawn container, verify GPU device is passed through
- The `ewm-session` script checks for `/dev/dri/card0`

### Elisp Module Loading

For Emacs to load the dynamic module:
1. Emacs must be compiled with dynamic module support (pgtk build has this)
2. The `.so` library must be in a known location
3. Elisp code must call `(require 'ewm)` when `EWM_SESSION=1`

Example in `~/.emacs.d/init.el`:
```elisp
(when (getenv "EWM_SESSION")
  (require 'ewm)
  (ewm-start))
```

## Build Notes

### Rust Dependencies

EWM uses several Rust crates. The build relies on Cargo to fetch dependencies from crates.io. If you need hermetic builds with vendored dependencies, you can:

1. Run the vendoring script (from Guix setup):
   ```bash
   ./scripts/vendor-ewm.sh
   ```

2. Create a vendored tarball in `vendor/ewm-vendored.tar.gz`

3. Modify `default.nix` to extract and use the vendored tarball

Currently, the Nix build fetches from crates.io during `nix build`. This requires internet access but is simpler for development.

### Library Linking

The RUSTFLAGS ensure libEGL and libwayland-client are properly linked:
```
-C link-arg=-lEGL
-C link-arg=-lwayland-client
```

This is necessary because the compositor uses these libraries via FFI (dlopen).

## Testing

### Verify Build

```bash
# Check if packages build successfully
nix build '.#ewm-core' -v
nix build '.#emacs-ewm' -v
```

### Verify Elisp Loading

```bash
# Start EWM session
~/.nix-profile/bin/ewm-session

# In Emacs, verify module is loaded:
M-x describe-variable EWM_SESSION
(require 'ewm)  # Should load without error
```

### Verify GPU Access

```bash
# Check device accessibility
ls -l /dev/dri/card0

# Or run from within EWM:
M-x shell
wayland-info  # Should show Wayland compositors
```

## Related Files

- `flake.nix` — Flake integration with ewm-overlay
- `home.nix` — Home Manager integration
- `guix-channel/ewm/packages.scm` — Original Guix package definitions
- `scripts/vendor-ewm.sh` — Cargo vendoring script
- `emacs-config.scm` — Emacs configuration (includes EWM packages)

## Upstream

- **EWM Repository:** https://codeberg.org/ezemtsov/ewm
- **Commit:** 43f6b5ec82b336aef1acf0f78a016ba909a62b4d
- **License:** GPL-3.0+

## Troubleshooting

### Module fails to load
1. Verify Emacs has dynamic module support: `(featurep 'dynamic-modules)`
2. Check library path: `echo $LD_LIBRARY_PATH`
3. Verify `.so` exists: `ls ~/.nix-profile/lib/libewm_core.so`

### Rendering issues
1. Verify GPU device: `/dev/dri/card0` accessible
2. Check Wayland backend: `echo $GDK_BACKEND`
3. Verify RADV driver (AMD GPU): `glxinfo | grep "OpenGL"`

### Build fails
1. Ensure llvm is available: `which clang`
2. Check LIBCLANG_PATH: `echo $LIBCLANG_PATH`
3. Review full build log: `nix build '.#ewm-core' -v 2>&1 | tail -50`

## Future Work

- [ ] Vendor Cargo dependencies for fully offline builds
- [ ] Add systemd user service for EWM session management
- [ ] Create launcher desktop entry
- [ ] Integrate with GNOME/KDE session systems
- [ ] Add Wayland session file for login managers
