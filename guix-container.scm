;;; Guix System Container Configuration for NixOS
;;; This defines a Guix System container with EXWM, Niri, and Wayland support
;;; Designed to run as a container on NixOS (NixOS handles boot/network/SSH)

(use-modules (gnu)
             (gnu system)
             (gnu system file-systems)
             (gnu packages)
             (gnu packages emacs)
             (gnu packages emacs-xyz)
             (gnu packages wm)
             (gnu packages xdisorg)
             (gnu packages xorg)
             (gnu packages linux)
             (gnu packages freedesktop)
             (gnu packages gnome)
             (gnu packages gtk)
             (gnu packages glib)
             (gnu packages fonts)
             (gnu packages fontutils)
             (gnu packages terminals)
             (gnu packages shells)
             (gnu packages version-control)
             (gnu packages base)
             (gnu packages coreutils)
             (gnu packages admin)
             (gnu packages commencement)
             (gnu packages node)               ; For Node.js/npx (Claude Code)
             (gnu packages python)             ; For Python3
             (gnu packages python-xyz)         ; Python packages
             (gnu packages python-web)         ; Web-related Python packages
             (gnu packages rust-apps)          ; Rust CLI tools
             (gnu packages curl)               ; HTTP tools
             (gnu packages tls)                ; SSL/TLS support
             (gnu packages compression)        ; Compression utilities
             (gnu services)
             (gnu services base)
             (gnu services dbus)
             (gnu services xorg)
             (gnu services desktop)
             (gnu services shepherd)
             (gnu services sddm)
             (gnu services mcron)              ; For scheduled Guix updates
             (gnu home)
             (guix gexp)
             (guix packages)
             (guix download)
             (guix build-system emacs)
             (srfi srfi-1))

;;; ---------------------------------------------------------------------------
;;; Package Definitions
;;; ---------------------------------------------------------------------------

;; Emacs pgtk (pure GTK for native Wayland support)
;; Note: This may need adjustment based on your Guix channel configuration
;; Use false-if-exception for safer fallback handling
(define emacs-pgtk
  (or (false-if-exception emacs-pgtk)
      (false-if-exception emacs-next-pgtk)
      emacs))  ; Final fallback to standard emacs

;; Core Emacs packages for EXWM
(define %emacs-packages
  (list emacs-exwm
        ;; emacs-exwm-mff          ; Mouse follows focus for EXWM (commented out - may not be available)
        emacs-desktop-environment ; Desktop environment integration
        emacs-pdf-tools
        emacs-vterm
        emacs-magit
        emacs-which-key
        emacs-vertico
        emacs-orderless
        emacs-marginalia
        emacs-consult
        emacs-embark
        emacs-corfu
        emacs-cape))

;; Wayland compositor and tools
(define %wayland-packages
  (list ;; Compositors
        ;; niri  ; Uncomment when niri is available in Guix
        sway                    ; Alternative Wayland compositor (fallback)

        ;; Wayland core
        wayland
        wayland-protocols
        wlroots

        ;; Wayland tools
        wl-clipboard            ; Clipboard support
        wlsunset                ; Night light / blue light filter
        waybar                  ; Status bar
        wofi                    ; Application launcher
        mako                    ; Notification daemon
        grim                    ; Screenshot tool
        slurp                   ; Region selection
        swaylock                ; Screen locker
        swayidle                ; Idle management
        wev                     ; Wayland event viewer (debugging)
        wtype                   ; Wayland xdotool equivalent

        ;; XWayland for X11 app compatibility
        xorg-server-xwayland))

;; Desktop integration packages
(define %desktop-packages
  (list ;; D-Bus and portals
        dbus
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-utils

        ;; GTK and theming
        gtk+
        adwaita-icon-theme
        hicolor-icon-theme

        ;; Fonts
        font-google-noto
        font-liberation
        font-dejavu
        font-fira-code
        font-iosevka
        fontconfig

        ;; Audio (PipeWire/PulseAudio handled at system level)
        pipewire
        wireplumber

        ;; Terminal and shell
        foot                    ; Wayland-native terminal
        alacritty               ; GPU-accelerated terminal
        zsh

        ;; File management
        glib                    ; GIO/GVfs support
        ))

;; Development essentials
(define %development-packages
  (list git
        make
        gcc-toolchain
        pkg-config
        coreutils
        findutils
        grep
        sed
        gawk
        which
        htop
        tree
        file
        less
        man-db))

;; AI Tools and MCP Server Dependencies
;; These packages support Claude Code, npx, and various MCP servers
(define %ai-tools-packages
  (list ;; Node.js ecosystem (for Claude Code, npx, MCP servers)
        node-lts                        ; Node.js LTS for stability
        ;; Note: npm is included with node-lts

        ;; Python ecosystem (for AI tools and MCP servers)
        python                          ; Python 3
        python-pip                      ; pip for package management
        python-virtualenv               ; Virtual environments
        python-requests                 ; HTTP library (common MCP dependency)
        python-aiohttp                  ; Async HTTP (for async MCP servers)
        python-pydantic                 ; Data validation (MCP SDK dependency)
        python-click                    ; CLI framework
        python-rich                     ; Rich terminal output
        python-httpx                    ; Modern HTTP client
        python-websockets               ; WebSocket support for MCP

        ;; Build dependencies for native Python/Node packages
        openssl                         ; SSL/TLS support
        curl                            ; HTTP client
        unzip                           ; Archive extraction
        gzip
        tar

        ;; System libraries often needed by AI tools
        glibc                           ; C library
        libffi                          ; Foreign function interface
        zlib                            ; Compression library

        ;; Useful utilities for MCP server development
        jq                              ; JSON processor
        ripgrep                         ; Fast search (used by many tools)
        fd                              ; Modern find alternative
        ))

;; Combine all packages
(define %all-packages
  (append (list emacs-pgtk)
          %emacs-packages
          %wayland-packages
          %desktop-packages
          %development-packages
          %ai-tools-packages))

;;; ---------------------------------------------------------------------------
;;; Service Definitions
;;; ---------------------------------------------------------------------------

;; EXWM session script for Wayland (using XWayland)
(define exwm-wayland-session
  (program-file
   "exwm-wayland-session"
   #~(begin
       (use-modules (ice-9 format))
       ;; Set up environment for Wayland
       (setenv "XDG_SESSION_TYPE" "wayland")
       (setenv "XDG_CURRENT_DESKTOP" "EXWM")
       (setenv "MOZ_ENABLE_WAYLAND" "1")
       (setenv "QT_QPA_PLATFORM" "wayland")
       (setenv "SDL_VIDEODRIVER" "wayland")
       (setenv "GDK_BACKEND" "wayland")
       (setenv "_JAVA_AWT_WM_NONREPARENTING" "1")

       ;; Start Emacs with EXWM
       (execl #$(file-append emacs-pgtk "/bin/emacs")
              "emacs"
              "--eval" "(require 'exwm)"
              "--eval" "(exwm-enable)"))))

;; Niri session script (when available)
(define niri-session
  (program-file
   "niri-session"
   #~(begin
       (setenv "XDG_SESSION_TYPE" "wayland")
       (setenv "XDG_CURRENT_DESKTOP" "niri")
       (setenv "MOZ_ENABLE_WAYLAND" "1")
       (setenv "QT_QPA_PLATFORM" "wayland")
       ;; Niri will be started here when package is available
       ;; (execl #$(file-append niri "/bin/niri") "niri")
       ;; For now, fall back to sway
       (execl #$(file-append sway "/bin/sway") "sway"))))

;; Desktop session entries
(define %desktop-sessions
  (list
   ;; EXWM on Wayland session
   (plain-file "exwm-wayland.desktop"
               "[Desktop Entry]
Name=EXWM (Wayland)
Comment=Emacs Window Manager on Wayland via XWayland
Exec=exwm-wayland-session
Type=Application
DesktopNames=EXWM")

   ;; Niri session
   (plain-file "niri.desktop"
               "[Desktop Entry]
Name=Niri
Comment=Scrollable-tiling Wayland compositor
Exec=niri-session
Type=Application
DesktopNames=niri")))

;;; ---------------------------------------------------------------------------
;;; User Shepherd Services (for Guix Home integration)
;;; ---------------------------------------------------------------------------

;; User service for PipeWire audio
(define (pipewire-user-service)
  (shepherd-service
   (provision '(pipewire))
   (documentation "PipeWire audio/video server")
   (start #~(make-forkexec-constructor
             (list #$(file-append pipewire "/bin/pipewire"))))
   (stop #~(make-kill-destructor))))

;; User service for WirePlumber (PipeWire session manager)
(define (wireplumber-user-service)
  (shepherd-service
   (requirement '(pipewire))
   (provision '(wireplumber))
   (documentation "WirePlumber PipeWire session manager")
   (start #~(make-forkexec-constructor
             (list #$(file-append wireplumber "/bin/wireplumber"))))
   (stop #~(make-kill-destructor))))

;; User service for PipeWire-PulseAudio compatibility
(define (pipewire-pulse-user-service)
  (shepherd-service
   (requirement '(pipewire))
   (provision '(pipewire-pulse))
   (documentation "PipeWire PulseAudio compatibility")
   (start #~(make-forkexec-constructor
             (list #$(file-append pipewire "/bin/pipewire-pulse"))))
   (stop #~(make-kill-destructor))))

;; User service for mako notifications
(define (mako-user-service)
  (shepherd-service
   (provision '(mako))
   (documentation "Mako notification daemon")
   (start #~(make-forkexec-constructor
             (list #$(file-append mako "/bin/mako"))))
   (stop #~(make-kill-destructor))))

;;; ---------------------------------------------------------------------------
;;; Guix Update Control (mcron jobs)
;;; ---------------------------------------------------------------------------

;; Script to perform guix pull and optionally trigger NixOS rebuild
(define guix-update-script
  (program-file
   "guix-update"
   #~(begin
       (use-modules (ice-9 format)
                    (ice-9 popen)
                    (ice-9 rdelim))

       (define (log-message msg)
         (let ((timestamp (strftime "%Y-%m-%d %H:%M:%S" (localtime (current-time)))))
           (format #t "[~a] ~a~%" timestamp msg)))

       (define (run-command cmd)
         (log-message (format #f "Running: ~a" cmd))
         (let* ((port (open-input-pipe cmd))
                (output (read-delimited "" port))
                (status (close-pipe port)))
           (when (not (string-null? output))
             (display output))
           (zero? (status:exit-val status))))

       ;; Perform guix pull
       (log-message "Starting Guix update...")
       (if (run-command "guix pull")
           (begin
             (log-message "Guix pull completed successfully")

             ;; Check if NixOS rebuild is requested
             (when (file-exists? "/var/lib/guix-nixos-sync/trigger-rebuild")
               (log-message "NixOS rebuild trigger found")
               ;; Signal NixOS to rebuild (via shared file or D-Bus)
               (when (file-exists? "/run/host/trigger-nixos-rebuild")
                 (call-with-output-file "/run/host/trigger-nixos-rebuild"
                   (lambda (port)
                     (format port "rebuild-requested-by-guix~%"))))
               ;; Remove trigger file
               (delete-file "/var/lib/guix-nixos-sync/trigger-rebuild"))

             ;; Optionally reconfigure system
             (when (file-exists? "/var/lib/guix-nixos-sync/auto-reconfigure")
               (log-message "Auto-reconfigure enabled, running guix system reconfigure...")
               (run-command "guix system reconfigure /etc/guix/system.scm")))

           (log-message "Guix pull failed!")))))

;; Script to manually trigger NixOS rebuild from Guix container
(define trigger-nixos-rebuild-script
  (program-file
   "trigger-nixos-rebuild"
   #~(begin
       (use-modules (ice-9 format))

       (define trigger-file "/run/host/trigger-nixos-rebuild")
       (define sync-dir "/var/lib/guix-nixos-sync")

       ;; Ensure sync directory exists
       (unless (file-exists? sync-dir)
         (mkdir sync-dir))

       ;; Create trigger file for next guix update
       (call-with-output-file (string-append sync-dir "/trigger-rebuild")
         (lambda (port)
           (format port "~a~%" (current-time))))

       ;; If host trigger file is accessible, write directly
       (when (file-exists? (dirname trigger-file))
         (call-with-output-file trigger-file
           (lambda (port)
             (format port "rebuild-requested~%"))))

       (format #t "NixOS rebuild triggered. Will execute on next sync.~%"))))

;; mcron job for daily guix pull (runs at 3 AM)
(define guix-pull-job
  #~(job '(next-hour '(3))
         #$(file-append guix-update-script)
         "Daily Guix pull"))

;; mcron job for weekly garbage collection (Sunday at 4 AM)
(define guix-gc-job
  #~(job '(next-day-from (next-hour '(4)) '(0))  ; Sunday
         "guix gc --delete-generations=30d"
         "Weekly Guix garbage collection"))

;;; ---------------------------------------------------------------------------
;;; Device Passthrough Configuration
;;; ---------------------------------------------------------------------------

;; Device nodes to pass through to container
;; Full /dev passthrough for GPU, audio, input devices
(define %container-devices
  '(;; GPU devices
    "/dev/dri"                          ; Direct Rendering Infrastructure
    "/dev/nvidia0"                      ; NVIDIA GPU (if present)
    "/dev/nvidiactl"                    ; NVIDIA control device
    "/dev/nvidia-modeset"               ; NVIDIA modeset
    "/dev/nvidia-uvm"                   ; NVIDIA unified memory
    "/dev/nvidia-uvm-tools"             ; NVIDIA UVM tools

    ;; Audio devices
    "/dev/snd"                          ; ALSA sound devices
    "/dev/dsp"                          ; OSS compatibility

    ;; Input devices
    "/dev/input"                        ; Input event devices
    "/dev/uinput"                       ; User-space input

    ;; Other useful devices
    "/dev/shm"                          ; Shared memory
    "/dev/fuse"                         ; FUSE filesystem
    "/dev/net/tun"                      ; TUN/TAP networking
    "/dev/kvm"                          ; KVM virtualization (if needed)
    "/dev/vhost-net"                    ; vhost networking
    "/dev/usb"                          ; USB devices
    "/dev/bus/usb"))                    ; USB bus

;; File systems for device passthrough (bind mounts from host)
(define %device-file-systems
  (map (lambda (dev)
         (file-system
           (device dev)
           (mount-point dev)
           (type "none")
           (flags '(bind-mount))
           (check? #f)
           (create-mount-point? #t)))
       (filter file-exists? %container-devices)))

;;; ---------------------------------------------------------------------------
;;; D-Bus Host Integration
;;; ---------------------------------------------------------------------------

;; Configuration for connecting to host D-Bus
(define %host-dbus-socket "/run/host/dbus/system_bus_socket")
(define %host-dbus-session-socket "/run/host/dbus/session_bus_socket")

;; Environment variables for D-Bus integration
(define %dbus-environment
  `(("DBUS_SYSTEM_BUS_ADDRESS" .
     ,(string-append "unix:path=" %host-dbus-socket))
    ("DBUS_SESSION_BUS_ADDRESS" .
     ,(string-append "unix:path=" %host-dbus-session-socket))))

;; File system bind mount for host D-Bus socket
(define dbus-host-file-system
  (file-system
    (device "/run/dbus")
    (mount-point "/run/host/dbus")
    (type "none")
    (flags '(bind-mount))
    (check? #f)
    (create-mount-point? #t)))

;;; ---------------------------------------------------------------------------
;;; System Configuration
;;; ---------------------------------------------------------------------------

(operating-system
  ;; Container mode - NixOS handles the kernel and bootloader
  (host-name "guix-container")
  (timezone "UTC")
  (locale "en_US.UTF-8")

  ;; No bootloader needed in container mode
  (bootloader (bootloader-configuration
               (bootloader grub-bootloader)
               (targets '("/dev/null"))))  ; Dummy target for container

  ;; Filesystem configuration with device passthrough
  (file-systems
   (append
    ;; Root filesystem
    (list (file-system
            (device "none")
            (mount-point "/")
            (type "tmpfs")))

    ;; D-Bus host socket bind mount
    (list dbus-host-file-system)

    ;; Device passthrough bind mounts
    ;; Note: These are conditionally mounted if devices exist on host
    %device-file-systems))

  ;; User configuration
  (users (cons* (user-account
                  (name "user")
                  (comment "Container User")
                  (group "users")
                  (home-directory "/home/user")
                  (supplementary-groups '("wheel" "audio" "video" "input"
                                          "kvm" "render" "dialout")))
                %base-user-accounts))

  ;; All packages available system-wide
  (packages (append %all-packages
                    %base-packages
                    ;; Additional scripts for system management
                    (list guix-update-script
                          trigger-nixos-rebuild-script)))

  ;; Services configuration
  ;; Note: Boot, networking, and SSH are handled by NixOS
  (services
   (append
    ;; D-Bus service (required for desktop integration)
    ;; Configured to also connect to host D-Bus
    (list (service dbus-root-service-type))

    ;; Polkit for privilege escalation
    (list (service polkit-service-type))

    ;; elogind for session/seat management
    (list (service elogind-service-type))

    ;; UPower for power management
    (list (service upower-service-type))

    ;; Font cache service
    (list (service fontconfig-file-system-service-type))

    ;; mcron service for scheduled Guix updates
    (list (service mcron-service-type
                   (mcron-configuration
                    (jobs (list guix-pull-job
                                guix-gc-job)))))

    ;; SDDM display manager (optional, can also start sessions manually)
    ;; Uncomment if you want a graphical login
    ;; (list (service sddm-service-type
    ;;                (sddm-configuration
    ;;                 (display-server "wayland"))))

    ;; XDG portal services for Wayland
    (list (simple-service 'xdg-portal-env
                          session-environment-service-type
                          (append
                           ;; Wayland environment
                           '(("XDG_CURRENT_DESKTOP" . "sway")
                             ("XDG_SESSION_TYPE" . "wayland"))
                           ;; D-Bus host integration
                           %dbus-environment
                           ;; Node.js / npm configuration for global installs
                           '(("NPM_CONFIG_PREFIX" . "/home/user/.npm-global")
                             ("PATH" . "/home/user/.npm-global/bin:$PATH")))))

    ;; Minimal base services (excluding networking, SSH, etc.)
    (modify-services %base-services
      ;; Remove services handled by NixOS
      (delete console-font-service-type)
      (delete mingetty-service-type)
      (delete login-service-type)
      (delete virtual-terminal-service-type)
      (delete agetty-service-type)
      (delete nscd-service-type)))))

;;; ---------------------------------------------------------------------------
;;; Guix Home Configuration Template
;;; ---------------------------------------------------------------------------

;;; This template can be used with `guix home` for user-level configuration
;;; Save this section separately as home-config.scm if needed

;; (use-modules (gnu home)
;;              (gnu home services)
;;              (gnu home services shepherd)
;;              (gnu home services shells)
;;              (gnu services)
;;              (guix gexp))

;; (home-environment
;;  (packages %all-packages)
;;  (services
;;   (list
;;    ;; Shepherd user services
;;    (service home-shepherd-service-type
;;             (home-shepherd-configuration
;;              (services (list (pipewire-user-service)
;;                              (wireplumber-user-service)
;;                              (pipewire-pulse-user-service)
;;                              (mako-user-service)))))
;;
;;    ;; Shell configuration
;;    (service home-zsh-service-type
;;             (home-zsh-configuration
;;              (environment-variables
;;               '(("XDG_SESSION_TYPE" . "wayland")
;;                 ("MOZ_ENABLE_WAYLAND" . "1")
;;                 ("QT_QPA_PLATFORM" . "wayland"))))))))

;;; ---------------------------------------------------------------------------
;;; Notes for Integration with NixOS
;;; ---------------------------------------------------------------------------

;;; To run this container on NixOS:
;;;
;;; 1. Build the container:
;;;    guix system container guix-container.scm
;;;
;;; 2. Or build as a Docker-style image:
;;;    guix system image -t docker guix-container.scm
;;;
;;; 3. For development, use guix shell:
;;;    guix shell emacs-pgtk emacs-exwm sway wayland -- sway
;;;
;;; 4. To use Guix Home for user configuration:
;;;    guix home reconfigure home-config.scm
;;;
;;; NixOS should provide:
;;; - Kernel and modules
;;; - Network configuration
;;; - SSH access
;;; - Hardware drivers (GPU, etc.)
;;; - systemd-nspawn or other container runtime
;;; - D-Bus system bus socket at /run/dbus
;;; - Create /run/host/trigger-nixos-rebuild for Guix-triggered rebuilds
;;;
;;; This Guix container provides:
;;; - EXWM desktop environment
;;; - Niri/Sway Wayland compositor
;;; - All user-space applications
;;; - User services via Shepherd
;;; - Guix Home integration

;;; ---------------------------------------------------------------------------
;;; AI Tools and MCP Server Support
;;; ---------------------------------------------------------------------------

;;; The container includes Node.js and Python for AI tooling:
;;;
;;; 1. Claude Code (via npx):
;;;    npx @anthropic-ai/claude-code
;;;
;;; 2. Install MCP servers globally:
;;;    npm install -g @modelcontextprotocol/server-filesystem
;;;    npm install -g @modelcontextprotocol/server-github
;;;
;;; 3. Python-based MCP servers:
;;;    pip install mcp
;;;    pip install mcp-server-git
;;;
;;; 4. NPM global packages are installed to ~/.npm-global
;;;    The PATH is configured automatically

;;; ---------------------------------------------------------------------------
;;; Device Passthrough
;;; ---------------------------------------------------------------------------

;;; Full /dev passthrough is configured for:
;;; - GPU: /dev/dri, /dev/nvidia* (for CUDA, OpenGL, Vulkan)
;;; - Audio: /dev/snd, /dev/dsp (ALSA, OSS)
;;; - Input: /dev/input, /dev/uinput (keyboards, mice, gamepads)
;;; - Misc: /dev/shm, /dev/fuse, /dev/kvm
;;;
;;; Run container with these systemd-nspawn flags:
;;;   --bind=/dev/dri
;;;   --bind=/dev/snd
;;;   --bind=/dev/input
;;;   --property=DeviceAllow='char-drm rwm'
;;;   --property=DeviceAllow='char-alsa rwm'
;;;   --property=DeviceAllow='char-input rwm'
;;;
;;; Or use --bind-all-devices for full passthrough (less secure)

;;; ---------------------------------------------------------------------------
;;; D-Bus Integration
;;; ---------------------------------------------------------------------------

;;; Host D-Bus socket is bind-mounted to /run/host/dbus/
;;; Environment variables are set automatically:
;;;   DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/host/dbus/system_bus_socket
;;;
;;; NixOS configuration needed:
;;;   services.dbus.enable = true;
;;;   # Bind mount for container access
;;;   systemd.tmpfiles.rules = [
;;;     "d /run/host/dbus 0755 root root -"
;;;   ];

;;; ---------------------------------------------------------------------------
;;; Guix-Controlled Updates
;;; ---------------------------------------------------------------------------

;;; mcron jobs are configured for automatic updates:
;;;
;;; 1. Daily guix pull at 3 AM
;;; 2. Weekly garbage collection on Sundays at 4 AM
;;;
;;; To trigger NixOS rebuild from Guix:
;;;   trigger-nixos-rebuild
;;;
;;; To enable auto-reconfigure after guix pull:
;;;   touch /var/lib/guix-nixos-sync/auto-reconfigure
;;;
;;; Manual Guix update:
;;;   guix-update
;;;
;;; NixOS can monitor /run/host/trigger-nixos-rebuild for rebuild requests

