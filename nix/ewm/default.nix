{ rustPlatform
, fetchFromCodeberg
, pkg-config
, clang
, llvm
, libEGL
, libwayland-client
, libdrm
, mesa
, libinput
, libxkbcommon
, seatd
, eudev
, pipewire
, glib
, lib
}:

rustPlatform.buildRustPackage rec {
  pname = "ewm-core";
  version = "0.1.0-git.43f6b5e";

  src = fetchFromCodeberg {
    owner = "ezemtsov";
    repo = "ewm";
    rev = "43f6b5ec82b336aef1acf0f78a016ba909a62b4d";
    sha256 = "sha256-6hU8N0Hq5lCc0fFXV9xdKzY3fH0nK5pL1V8wQ2nJ3eA=";
  };

  # Cargo hash will be computed on first build.
  # To compute this, run: nix build '.#ewm-core' 2>&1 | grep cargoHash
  # Then update this value.
  # Temporarily use null to let Nix compute it.
  cargoHash = null;

  sourceRoot = "${src.name}/compositor";

  nativeBuildInputs = [
    pkg-config
    clang
    llvm
  ];

  buildInputs = [
    libEGL
    libwayland-client
    libdrm
    mesa
    libinput
    libxkbcommon
    seatd
    eudev
    pipewire
    glib
  ];

  # Build configuration flags
  env = {
    LIBCLANG_PATH = "${llvm}/lib";
  };

  postUnpack = ''
    # The source root is already set to compositor dir above
    # but we need the lisp directory which is at the root level
    mkdir -p "$sourceRoot/../lisp-files"
    cp -r "$src/lisp"/* "$sourceRoot/../lisp-files/" || true
  '';

  RUSTFLAGS = [
    "-C" "link-arg=-Wl,--push-state,--no-as-needed"
    "-C" "link-arg=-lEGL"
    "-C" "link-arg=-lwayland-client"
    "-C" "link-arg=-Wl,--pop-state"
  ];

  buildFeatures = [ "screencast" ];

  postInstall = ''
    # Install the dynamic module
    mkdir -p "$out/lib"
    install -m 0644 "target/release/libewm_core.so" "$out/lib/"

    # Create a symlink for Emacs module loading
    mkdir -p "$out/share/emacs/site-lisp"
    ln -s "$out/lib/libewm_core.so" "$out/share/emacs/site-lisp/ewm-core.so"

    # Install Elisp files if they exist
    if [ -d "../lisp-files" ]; then
      for f in ../lisp-files/*.el; do
        [ -e "$f" ] && install -m 0644 "$f" "$out/share/emacs/site-lisp/"
      done
    fi

    # Install session file if it exists
    if [ -f "../resources/ewm-session" ]; then
      mkdir -p "$out/bin"
      install -m 0755 "../resources/ewm-session" "$out/bin/ewm-session"
    fi

    # Install desktop file if it exists
    if [ -f "../resources/ewm.desktop" ]; then
      mkdir -p "$out/share/wayland-sessions"
      install -m 0644 "../resources/ewm.desktop" "$out/share/wayland-sessions/"
    fi
  '';

  meta = with lib; {
    description = "Emacs Wayland Manager — compositor as Emacs dynamic module";
    longDescription = ''
      EWM is a Wayland compositor that runs inside Emacs as a dynamic module.
      Wayland applications are rendered as Emacs buffers, letting you switch between
      code and apps with standard Emacs commands. The compositor runs on a separate
      thread, maintaining GUI responsiveness during Elisp evaluation.
    '';
    homepage = "https://codeberg.org/ezemtsov/ewm";
    license = licenses.gpl3Plus;
    maintainers = [];
    platforms = [ "x86_64-linux" ];
  };
}
