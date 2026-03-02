{ stdenv
, fetchFromCodeberg
, emacs-transient
, ewm-core
, lib
}:

stdenv.mkDerivation rec {
  pname = "emacs-ewm";
  version = "0.1.0-git.43f6b5e";

  src = fetchFromCodeberg {
    owner = "ezemtsov";
    repo = "ewm";
    rev = "43f6b5ec82b336aef1acf0f78a016ba909a62b4d";
    sha256 = "sha256-6hU8N0Hq5lCc0fFXV9xdKzY3fH0nK5pL1V8wQ2nJ3eA=";
  };

  buildInputs = [
    emacs-transient
    ewm-core
  ];

  # No compilation needed for Elisp - we just install source files
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p "$out/share/emacs/site-lisp"

    # Install all .el files from the lisp directory
    if [ -d "lisp" ]; then
      install -m 0644 lisp/*.el "$out/share/emacs/site-lisp/" 2>/dev/null || true
    fi

    # Create a symlink to the ewm-core.so library for Elisp to find
    mkdir -p "$out/lib"
    ln -s "${ewm-core}/lib/libewm_core.so" "$out/lib/libewm_core.so"

    # Also symlink it to site-lisp for convenience
    ln -s "${ewm-core}/lib/libewm_core.so" "$out/share/emacs/site-lisp/ewm-core.so"
  '';

  meta = with lib; {
    description = "Emacs integration package for EWM compositor";
    longDescription = ''
      This package provides the Elisp integration for EWM (Emacs Wayland Manager),
      including the module loader and helper functions to control the compositor
      from within Emacs.
    '';
    homepage = "https://codeberg.org/ezemtsov/ewm";
    license = licenses.gpl3Plus;
    maintainers = [];
    platforms = [ "x86_64-linux" ];
  };
}
