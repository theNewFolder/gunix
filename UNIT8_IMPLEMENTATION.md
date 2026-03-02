# Unit 8: EWM Compositor Packaging for Nix - Implementation Summary

## Overview

This unit migrates EWM (Emacs Wayland Manager) packaging from Guix to NixOS/Home Manager. EWM is a Wayland compositor that runs as a dynamic module inside Emacs, allowing Wayland applications to be rendered as Emacs buffers.

## Files Created/Modified

### New Files

1. **`nix/ewm/default.nix`**
   - Main Nix package for ewm-core (Rust compositor)
   - Uses `rustPlatform.buildRustPackage` for building Rust code
   - Fetches source from Codeberg: `https://codeberg.org/ezemtsov/ewm` (commit 43f6b5ec)
   - Builds dynamic library `libewm_core.so`
   - Dependencies: libEGL, libwayland-client, libdrm, mesa, libinput, libxkbcommon, seatd, eudev, pipewire, glib
   - Build features: screencast support enabled
   - Post-install: installs `.so` to `$out/lib` and creates symlink in `$out/share/emacs/site-lisp`

2. **`nix/ewm/emacs-ewm.nix`**
   - Elisp integration package (wrapper)
   - Simple `stdenv.mkDerivation` (no compilation needed)
   - Installs `.el` files from source
   - Creates symlinks to ewm-core library for Elisp discovery
   - Dependencies: emacs-transient, ewm-core

3. **`nix/ewm/README.md`**
   - Comprehensive documentation of EWM packaging
   - Build instructions
   - Integration guide
   - Known limitations and troubleshooting

### Modified Files

1. **`flake.nix`**
   - Added `ewm-overlay` that creates ewm-core and emacs-ewm packages
   - Integrated overlay into both `homeConfigurations` and `nixosConfigurations`
   - Uses overlay pattern for clean package composition

   Key changes:
   ```nix
   ewm-overlay = final: prev: {
     ewm-core = final.callPackage ./nix/ewm {};
     emacs-ewm = final.callPackage ./nix/ewm/emacs-ewm.nix {};
   };
   ```

2. **`home.nix`**
   - Added EWM packages to `home.packages`: ewm-core, emacs-ewm
   - Added EWM environment variables to `home.sessionVariables`:
     - `XDG_CURRENT_DESKTOP = "ewm"`
     - `EWM_SESSION = "1"`
   - Created `~/.nix-profile/bin/ewm-session` launcher script
     - Sets all necessary EWM environment variables
     - Validates `/dev/dri` availability for GPU passthrough
     - Launches Emacs with EWM support

## Architecture

### Package Dependencies

```
ewm-core (Rust)
├── libEGL
├── libwayland-client
├── libdrm
├── mesa
├── libinput
├── libxkbcommon
├── seatd
├── eudev
├── pipewire
└── glib

emacs-ewm (Elisp)
├── ewm-core
└── emacs-transient
```

### Build Process

1. Fetch source from Codeberg
2. Build Rust compositor in `compositor/` directory
3. Run `cargo build --release --features screencast`
4. Install `libewm_core.so` to `$out/lib`
5. Install Elisp files from `lisp/` directory
6. Create symlinks for Emacs module discovery

### Runtime Setup

```
EWM_SESSION=1 emacs
  ↓
Emacs starts in EWM mode (XDG_CURRENT_DESKTOP=ewm)
  ↓
Early in init.el: (when (getenv "EWM_SESSION") (require 'ewm))
  ↓
Emacs loads libewm_core.so via (require 'ewm)
  ↓
Compositor thread starts, waits for Wayland clients
  ↓
Wayland apps connect to compositor socket
  ↓
Apps render inside Emacs buffers
  ↓
C-x b switches between app buffers (standard Emacs)
```

## Integration Points

### With Home Manager
- Packages installed via `home.packages`
- Environment variables set via `home.sessionVariables`
- Session script created in `~/.nix-profile/bin/ewm-session`
- All declarative, rebuilds with `home-manager switch`

### With Emacs Configuration
- EWM Elisp code integrates with Emacs init
- Conditional loading: only when `EWM_SESSION=1`
- From `emacs-config.scm`: uses `%emacs-ewm` package list
- Example init code (to add to `~/.emacs.d/init.el`):
  ```elisp
  (when (getenv "EWM_SESSION")
    (require 'ewm)
    (ewm-start))
  ```

### With Wayland Ecosystem
- Wayland socket accessed via `XDG_RUNTIME_DIR`
- GPU rendering via `/dev/dri/card0` (AMD RADV driver)
- Libwayland protocol support
- Full Wayland surface composition

## Known Issues & Limitations

### 1. cargoHash Placeholder
- Currently set to `null` to let Nix compute it on first build
- On first build, Nix will show the correct hash
- Update `default.nix` with computed hash for deterministic builds
- Command: `nix build '.#ewm-core' 2>&1 | grep "hash mismatch" | grep -oP 'got: sha256-\K[^ ]*'`

### 2. Cargo Dependency Fetching
- Requires internet access during build (fetches from crates.io)
- For hermetic builds, could vendor dependencies into tarball
- Fallback: use `vendor/ewm-vendored.tar.gz` (from Guix setup)

### 3. Emacs Dynamic Module Support
- Requires Emacs built with `--with-modules` or pgtk variant
- Verify with: `(featurep 'dynamic-modules)` in Emacs
- nixpkgs `emacs-pgtk` has this enabled

### 4. GPU Passthrough (systemd-nspawn container)
- `/dev/dri` must be passed through from host
- Verify in `configuration.nix` container setup:
  ```nix
  bindMounts = [
    { hostPath = "/dev/dri"; mountPoint = "/dev/dri"; }
  ];
  ```

### 5. Library Path Discovery
- Elisp finds libewm_core.so via symlinks in `~/.nix-profile/lib`
- Alternative: set `LD_LIBRARY_PATH` in `ewm-session` script
- Consider adding to `emacs-ewm`: rpath setup for library discovery

## Testing Strategy

### Build-Time Tests
1. Syntax check flake: `nix flake check`
2. Dry-build packages: `nix build '.#ewm-core' --dry-run`
3. Actual build: `nix build '.#ewm-core'` (will compute cargoHash)

### Runtime Tests
1. Apply configuration: `home-manager switch`
2. Start EWM: `~/.nix-profile/bin/ewm-session`
3. Verify in Emacs:
   ```elisp
   M-x list-load-path-shadows
   (require 'ewm)  ; Should not error
   (getenv "EWM_SESSION")  ; Should return "1"
   ```
4. Test Wayland app launch:
   ```elisp
   M-x shell
   foot &  ; Terminal should appear as Emacs buffer
   ```

### GPU Testing
```bash
# In EWM Emacs:
M-x shell
# Run wayland client:
glxinfo | grep "OpenGL"  # Should show RADV renderer
mpv --help  # Should find wayland backend
```

## Comparison with Guix Implementation

| Aspect | Guix | Nix |
|--------|------|-----|
| Package file | `guix-channel/ewm/packages.scm` | `nix/ewm/default.nix` |
| Build system | GNU Build System (custom) | `rustPlatform.buildRustPackage` |
| Dependency handling | Guix modules | Nix stdenv/rustPlatform |
| Vendoring | `vendor/ewm-vendored.tar.gz` | Can use same, or fetch from crates.io |
| Integration | `guix-home.scm` + `manifest-emacs.scm` | `flake.nix` overlay + `home.nix` |
| Module loading | Via Guix service | Via Home Manager env vars + ewm-session script |
| Configuration | Guile Scheme | Nix language |

## Future Enhancements

1. **Vendored Cargo Dependencies**
   - Create hermetic builds using `vendor/ewm-vendored.tar.gz`
   - Update `default.nix` to extract and use vendored tarball

2. **Systemd User Service**
   - Create `ewm.service` in Home Manager
   - Auto-start EWM session at login

3. **Wayland Session File**
   - Create `ewm.desktop` in `$out/share/wayland-sessions/`
   - Allow login managers (greetd, sddm) to select EWM session

4. **Niri Fallback**
   - If EWM issues persist, switch to Niri compositor
   - Already configured in dotfiles: `dotfiles/niri/.config/niri/config.kdl`
   - Simpler Wayland compositor, fewer dependencies

5. **rpath/runpath for Libraries**
   - Add proper `runpath` to ewm-core.so
   - Avoid relying on `~/.nix-profile/lib` for library discovery
   - Use `patchelf` in post-install phase

## Rollback Strategy (30-day contingency)

If EWM becomes problematic:

1. **Short-term (30 days):** Keep Guix-packaged EWM in `~/.guix-profile`
   ```bash
   guix pull
   guix home reconfigure guix-home.scm  # Still uses ewm-core + emacs-ewm from Guix
   ```

2. **Medium-term:** Switch to Niri compositor
   ```bash
   # Modify home.nix to remove EWM, add Niri:
   # Set compositor in dotfiles/niri/config.kdl
   home-manager switch
   ```

3. **Long-term:** Contribute fixes upstream or improve packaging

## Files for Reference

- **Source repo:** https://codeberg.org/ezemtsov/ewm (commit 43f6b5ec)
- **Guix definitions:** `/home/gux/gunix/guix-channel/ewm/packages.scm`
- **Emacs config:** `/home/gux/gunix/emacs-config.scm` (includes EWM package lists)
- **Original Home:** `/home/gux/gunix/guix-home.scm` (%emacs-ewm + services)

## Success Criteria

- [x] EWM Nix packages created (`ewm-core`, `emacs-ewm`)
- [x] Flake integration with overlay pattern
- [x] Home Manager integration (packages + environment vars)
- [x] EWM session launcher script (`ewm-session`)
- [x] Documentation (README + this summary)
- [ ] Build succeeds with correct cargoHash (requires `nix build`)
- [ ] Elisp loads without error
- [ ] Wayland apps render in Emacs buffers
- [ ] GPU rendering works smoothly
- [ ] `/dev/dri` accessible in container

## Next Steps for Implementer

1. **Compute cargoHash:**
   ```bash
   nix build '.#ewm-core' 2>&1 | grep -E "hash mismatch|got:"
   # Update cargoHash in nix/ewm/default.nix
   ```

2. **Dry-build packages:**
   ```bash
   nix build '.#ewm-core' --dry-run
   nix build '.#emacs-ewm' --dry-run
   ```

3. **Apply configuration:**
   ```bash
   home-manager switch
   ```

4. **Test EWM:**
   ```bash
   ~/.nix-profile/bin/ewm-session
   # In Emacs: (require 'ewm)
   ```

5. **Debug if needed:**
   - Check build logs: `nix build '.#ewm-core' -v 2>&1 | tail -100`
   - Verify library: `ldd ~/.nix-profile/lib/libewm_core.so`
   - Test module: `emacs -l ~/.nix-profile/share/emacs/site-lisp/ewm.el`

## Additional Resources

- EWM Codeberg: https://codeberg.org/ezemtsov/ewm
- Nixpkgs Rust: https://nixos.wiki/wiki/Rust
- Home Manager: https://nix-community.github.io/home-manager/
- Wayland protocol: https://wayland.freedesktop.org/
- AMD RADV driver: https://docs.mesa3d.org/drivers/radv.html
