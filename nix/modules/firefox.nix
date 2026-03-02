# Firefox Configuration Module for Home Manager
# Wayland-native browser with performance optimizations
#
# Features:
#   - Wayland-native rendering (MOZ_ENABLE_WAYLAND=1)
#   - Hardware acceleration enabled
#   - Privacy-focused defaults
#   - Performance optimizations
#   - Clean profile management
#
# Enable via: programs.firefox.enable = true;

{ config, pkgs, lib, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;  # Wayland-native build

    # Preferences applied to all profiles
    preferences = {
      # ========================================================================
      # Wayland & Display Optimization
      # ========================================================================

      # Force Wayland backend
      "widget.wayland.vsync.enabled" = false;  # Disable Wayland vsync (use system)

      # Hardware acceleration
      "gfx.webrender.enabled" = true;
      "gfx.webrender.compositor" = true;
      "gfx.webrender.capable" = true;
      "gfx.webrender.force-disabled" = false;
      "layers.acceleration.force-enabled" = true;

      # GPU acceleration for all devices
      "layers.gpu-process.enabled" = true;

      # ========================================================================
      # Performance Optimization
      # ========================================================================

      # Memory optimization
      "browser.sessionstore.max_tabs_undo" = 5;  # Keep only 5 undo tabs
      "browser.sessionstore.interval" = 60000;   # Save session every 60s
      "browser.cache.jsbc_compression_level" = 9;

      # Network
      "network.http.keep-alive.timeout" = 300;
      "network.conn-manager.max_conns" = 256;
      "network.conn-manager.max_conns_per_host" = 12;
      "network.http.max-connections-per-server" = 8;
      "network.http.max-persistent-connections-per-server" = 6;

      # DNS optimization
      "network.trr.mode" = 0;  # Use system DNS (or 3 for DoH)
      "network.dns.disablePrefetch" = false;  # Allow DNS prefetch

      # Startup optimization
      "browser.startup.preconnect-count" = 4;
      "dom.disable_beforeunload" = false;

      # ========================================================================
      # Privacy & Security
      # ========================================================================

      # HTTPS-only mode
      "dom.security.https_only_mode" = true;
      "dom.security.https_only_mode_ever_enabled" = true;

      # Tracking protection (strict)
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;
      "privacy.trackingprotection.cryptomining.enabled" = true;
      "privacy.trackingprotection.fingerprinting.enabled" = true;

      # Disable telemetry
      "datareporting.healthreport.uploadEnabled" = false;
      "datareporting.policy.dataSubmissionEnabled" = false;
      "toolkit.telemetry.reportingpolicy.firstRun" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.archive.enabled" = false;

      # Enhanced tracking protection
      "privacy.trackingprotection.enabled" = true;
      "browser.contentblocking.category" = "strict";  # Strict blocking

      # Disable pocket
      "extensions.pocket.enabled" = false;
      "extensions.pocket.showHome" = false;

      # ========================================================================
      # User Experience
      # ========================================================================

      # Compact UI (less wasted space)
      "browser.compactmode.show" = true;

      # Home page and new tab
      "browser.startup.homepage_override.mstone" = "ignore";
      "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
      "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;

      # Sidebar
      "browser.ui.sidebars.sidebar_visibility_switch_buttons.enabled" = true;

      # Restore session
      "browser.sessionstore.resume_from_crash" = true;

      # Wayland native decorations
      "browser.tabs.drawInTitlebar" = false;  # Use system titlebar on Wayland

      # ========================================================================
      # Search Engine
      # ========================================================================

      # Use DuckDuckGo as default (privacy-focused)
      # or change to "Google", "Bing", "Wikipedia", "Amazon"
      "browser.search.defaultenginename" = "DuckDuckGo";
      "browser.search.defaultengine" = "DuckDuckGo";

      # Disable search suggestions
      "browser.search.suggest.enabled" = false;
      "browser.urlbar.suggest.searches" = false;

      # ========================================================================
      # Media & Codecs
      # ========================================================================

      # Enable hardware-accelerated video decoding
      "media.ffmpeg.vaapi.enabled" = true;  # AMD GPU acceleration
      "media.av1.enabled" = true;  # AV1 codec support

      # Autoplay settings
      "media.autoplay.default" = 1;  # Block autoplay of audio/video

      # ========================================================================
      # Misc Optimization
      # ========================================================================

      # Disable address bar suggestions
      "browser.urlbar.suggest.history" = false;
      "browser.urlbar.suggest.bookmarks" = false;

      # Disable pocket on new tab
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.feeds.snippets" = false;
    };

    # Profile configuration
    profiles.default = {
      name = "Default";
      isDefault = true;
      settings = {
        # ====================================================================
        # Profile-specific preferences
        # ====================================================================

        # Wayland session environment
        "MOZ_ENABLE_WAYLAND" = "1";

        # Extensions (if auto-installing)
        # "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      };

      # Bookmarks (optional)
      # Can be auto-imported from HTML file if needed
      bookmarks = [];

      # Search engines (can customize further)
      search = {
        engines = {
          "DuckDuckGo" = {
            urls = [{
              template = "https://duckduckgo.com/?q={searchTerms}";
            }];
            definedAliases = ["@d"];
          };
          "NixOS Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages?query={searchTerms}";
            }];
            definedAliases = ["@nix"];
          };
          "GitHub" = {
            urls = [{
              template = "https://github.com/search?q={searchTerms}";
            }];
            definedAliases = ["@gh"];
          };
        };
        default = "DuckDuckGo";
        order = ["DuckDuckGo" "NixOS Packages" "GitHub"];
      };
    };
  };

  # Home environment variables for Firefox
  home.sessionVariables = {
    # Already set globally, but ensure for Firefox:
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_DBUS_REMOTE = "1";  # D-Bus remote control
  };

  # Desktop shortcut (optional, for application launcher)
  xdg.desktopEntries.firefox = {
    name = "Firefox";
    exec = "firefox";
    icon = "firefox";
    categories = ["Network" "WebBrowser"];
    terminal = false;
  };

  # Optional: Add Firefox to home packages if not using programs.firefox
  # home.packages = [ pkgs.firefox-wayland ];
}
