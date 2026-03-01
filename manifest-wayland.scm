;; Guix Wayland Manifest
;; Wayland compositor, tools, and applications
;; Use with: guix package -m manifest-wayland.scm
;;       or: guix shell -m manifest-wayland.scm

(specifications->manifest
 '(;; ========================================================================
   ;; Wayland Compositors
   ;; ========================================================================
   ;; Note: dwl-guile is often compiled from source, but including base deps
   "wayland"                ; Wayland protocol library
   "weston"                 ; Reference Wayland compositor
   ;; "dwl-guile"            ; Tiling Wayland compositor (may need custom build)

   ;; ========================================================================
   ;; Wayland Libraries and Protocols
   ;; ========================================================================
   "libxkbcommon"           ; XKB keyboard handling
   "wayland-protocols"      ; Additional Wayland protocols
   "libwl-clipboard"        ; Wayland clipboard utilities

   ;; ========================================================================
   ;; Display and Input Tools
   ;; ========================================================================
   "wl-clipboard"           ; Wayland clipboard utilities (wl-copy/wl-paste)
   "cliphist"               ; Clipboard history manager
   "wtype"                  ; Text input tool for Wayland
   "wl-klipper"             ; Clipboard manager
   "xwayland"               ; X11 compatibility layer for Wayland

   ;; ========================================================================
   ;; Window Management and Configuration
   ;; ========================================================================
   "sway"                   ; i3-like Wayland compositor
   "swaylock"               ; Screen locker for Wayland
   "swayidle"               ; Idle management for Wayland
   "swaybg"                 ; Background image setter for Wayland
   "waybar"                 ; Polybar-like status bar for Wayland
   "wofi"                   ; Application launcher for Wayland
   "wlogout"                ; Logout menu for Wayland

   ;; ========================================================================
   ;; Screenshot and Screen Recording
   ;; ========================================================================
   "grim"                   ; Screenshot utility for Wayland
   "slurp"                  ; Region selection tool for Wayland
   "wf-recorder"            ; Screen recorder for Wayland
   "obs"                    ; Open Broadcaster Software (screen/stream)

   ;; ========================================================================
   ;; Screen Management
   ;; ========================================================================
   "wdisplays"              ; Display configuration GUI
   "kanshi"                 ; Dynamic display configuration

   ;; ========================================================================
   ;; Notification Daemon
   ;; ========================================================================
   "mako"                   ; Lightweight notification daemon
   "dunst"                  ; Alternative lightweight notification daemon

   ;; ========================================================================
   ;; Terminal Emulators (Wayland-native)
   ;; ========================================================================
   "foot"                   ; Fast Wayland terminal emulator
   "alacritty"              ; GPU-accelerated terminal
   "kitty"                  ; GPU-based terminal emulator
   "wezterm"                ; Rust-based GPU terminal

   ;; ========================================================================
   ;; Input and Keyboard Configuration
   ;; ========================================================================
   "libinput"               ; Input device library
   "libinput-gestures"      ; Touchpad gesture support

   ;; ========================================================================
   ;; Cursor and Pointer Management
   ;; ========================================================================
   "xcursor-themes"         ; X11 cursor theme files
   "libxcursor"             ; X cursor library

   ;; ========================================================================
   ;; File Managers (Wayland-compatible)
   ;; ========================================================================
   "thunar"                 ; Lightweight file manager
   "nemo"                   ; Modern file manager
   "pcmanfm-qt"             ; Qt-based file manager
   "nautilus"               ; GNOME file manager

   ;; ========================================================================
   ;; Web Browsers (Wayland-native)
   ;; ========================================================================
   "firefox-wayland"        ; Firefox with Wayland support
   "chromium"               ; Chromium browser (Wayland capable)

   ;; ========================================================================
   ;; Media Players
   ;; ========================================================================
   "mpv"                    ; Lightweight media player
   "vlc"                    ; VLC media player
   "ffmpeg"                 ; Multimedia framework

   ;; ========================================================================
   ;; Text Editors (Wayland-compatible)
   ;; ========================================================================
   "emacs-pgtk"             ; Emacs with pure GTK (Wayland native)
   "gedit"                  ; GNOME text editor
   "mousepad"               ; Lightweight text editor

   ;; ========================================================================
   ;; Development Tools for Wayland
   ;; ========================================================================
   "wayland-utils"          ; Wayland utilities (wayland-info, etc.)
   "wlroots"                ; Modular Wayland compositor library
   "libdecor"               ; Client-side window decoration support

   ;; ========================================================================
   ;; Color and Theme Management
   ;; ========================================================================
   "glib"                   ; GLib utilities
   "dbus"                   ; Message bus system
   "gsettings-desktop-schemas" ; Settings schemas for desktops

   ;; ========================================================================
   ;; Utility Applications
   ;; ========================================================================
   "imagemagick"            ; Image manipulation
   "feh"                    ; Image viewer
   "sxiv"                   ; Simple X image viewer (Wayland with Xwayland)
   "zathura"                ; Lightweight document viewer
   "pavucontrol"            ; PulseAudio volume control GUI
   "playerctl"              ; Media player control

   ;; ========================================================================
   ;; Network and Connectivity
   ;; ========================================================================
   "networkmanager"         ; Network management daemon
   "nm-applet"              ; NetworkManager GUI applet
   "blueman"                ; Bluetooth management GUI

   ;; ========================================================================
   ;; System Tools
   ;; ========================================================================
   "htop"                   ; Process viewer
   "btop"                   ; Modern resource monitor
   "lf"                     ; Terminal file manager
   "fzf"                    ; Fuzzy finder
   "ripgrep"                ; Fast recursive grep
   "fd"                     ; Simple find replacement

   ;; ========================================================================
   ;; Power Management
   ;; ========================================================================
   "elogind"                ; User login and power management
   ;; "acpi"                   ; ACPI battery utilities

   ;; ========================================================================
   ;; System Fonts
   ;; ========================================================================
   "font-fira-code"         ; Monospace font with ligatures
   "font-iosevka"           ; Customizable monospace font
   "font-google-noto"       ; Unicode font coverage
   "font-liberation"        ; Liberation fonts (metric compatible with Times, Arial, Courier)

   ;; ========================================================================
   ;; Audio and Sound
   ;; ========================================================================
   "pulseaudio"             ; PulseAudio sound server
   "alsa-utils"             ; ALSA utilities (alsamixer, etc.)
   "cmus"                   ; Console music player

   ))

;; ========================================================================
;; Usage Notes
;; ========================================================================
;;
;; Install all Wayland tools and applications:
;;   guix package -m manifest-wayland.scm
;;
;; Create a temporary Wayland development environment:
;;   guix shell -m manifest-wayland.scm
;;
;; Quick Wayland session with minimal tools:
;;   guix shell -m manifest-wayland.scm -- sway
;;
;; ========================================================================
;; Wayland Compositor Setup
;; ========================================================================
;;
;; For sway-based setup:
;;   1. Install manifest packages
;;   2. Create ~/.config/sway/config
;;   3. Start with: sway
;;
;; For dwl-guile (dynamic window layout + Guile scripting):
;;   1. Clone dwl-guile repository
;;   2. Build with: make
;;   3. Start with: dwl-guile
;;   (dwl-guile requires custom compilation; not available in Guix by default)
;;
;; For weston (reference compositor):
;;   weston
;;
;; ========================================================================
;; Configuration Files
;; ========================================================================
;;
;; Create configuration directories:
;;   mkdir -p ~/.config/sway
;;   mkdir -p ~/.config/waybar
;;   mkdir -p ~/.config/foot
;;   mkdir -p ~/.config/mako
;;   mkdir -p ~/.config/wofi
;;
;; Example locations:
;;   Sway config:     ~/.config/sway/config
;;   Waybar config:   ~/.config/waybar/config
;;   Foot config:     ~/.config/foot/foot.ini
;;   Mako config:     ~/.config/mako/config
;;   Wofi config:     ~/.config/wofi/config
;;
;; ========================================================================
;; Integration with Other Manifests
;; ========================================================================
;;
;; To create a complete dev environment with Wayland:
;;   guix shell -m manifest-wayland.scm -m manifest-dev.scm
;;
;; To create a complete Emacs + Wayland environment:
;;   guix shell -m manifest-wayland.scm -m manifest-emacs.scm
;;
;; ========================================================================
;; Useful Wayland Tools
;; ========================================================================
;;
;; Clipboard:
;;   wl-copy  : Copy to clipboard (pipe output)
;;   wl-paste : Paste from clipboard
;;   Example: echo "hello" | wl-copy
;;
;; Screenshots:
;;   grim -o HDMI-1 screenshot.png           # Full monitor
;;   grim -g \"0,0 1920x1080\" screenshot.png # Region
;;   grim - | slurp | wl-copy               # Screenshot to clipboard
;;
;; Screen Recording:
;;   wf-recorder -o /tmp/video.mp4
;;   wf-recorder -o /tmp/video.mp4 -d 30    # 30 second recording
;;
;; Display Info:
;;   wayland-info                            # Wayland protocol support
;;   wdisplays                               # GUI for display configuration
;;
;; Input Debugging:
;;   libinput list-devices                   # Show input devices
;;   libinput list-touchpads                 # Show touchpads
;;
;; ========================================================================
;; Known Limitations and Workarounds
;; ========================================================================
;;
;; 1. Some X11-only apps can run via XWayland:
;;      WAYLAND_DISPLAY= XDG_SESSION_TYPE=x11 application-name
;;
;; 2. For screen sharing and streaming:
;;      - Use pipewire instead of pulseaudio
;;      - OBS with additional Wayland support packages
;;
;; 3. Input method support (IM):
;;      - Install: ibus fcitx5 (requires additional setup)
;;
;; 4. Wayland native tools are still evolving:
;;      - Some features may be available in newer versions
;;      - Check project repositories for latest information
;;
;; ========================================================================
