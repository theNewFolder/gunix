;; Guix Development Tools Manifest
;; Development tools: compilers, debuggers, LSP servers, and build utilities
;; Use with: guix package -m manifest-dev.scm
;;       or: guix shell -m manifest-dev.scm

(specifications->manifest
 '(;; ========================================================================
   ;; Language-Specific Compilers and Interpreters
   ;; ========================================================================
   "gcc-toolchain"          ; GNU C/C++ Compiler with support libraries
   "gccgo"                  ; Go compiler from GCC
   "rustup"                 ; Rust toolchain installer (alternative to rust)
   "rust"                   ; Rust programming language compiler
   "clang"                  ; LLVM C/C++ compiler
   "llvm"                   ; LLVM compiler infrastructure
   "go"                     ; Go programming language
   "python"                 ; Python interpreter
   "python-pip"             ; Python package installer
   "node"                   ; Node.js JavaScript runtime
   "ruby"                   ; Ruby programming language
   "ghc"                    ; Glasgow Haskell Compiler
   "nasm"                   ; Netwide Assembler
   "perl"                   ; Perl programming language

   ;; ========================================================================
   ;; Build Tools and Package Managers
   ;; ========================================================================
   "make"                   ; GNU Make build automation
   "cmake"                  ; Cross-platform build system
   "meson"                  ; Fast build system
   "ninja"                  ; Small build system
   "autoconf"               ; GNU Autoconf macro package
   "automake"               ; GNU Automake build tool
   "libtool"                ; GNU Libtool for building libraries
   "pkg-config"             ; Helper tool for build flags
   "cargo"                  ; Rust package manager
   "bundler"                ; Ruby dependency manager

   ;; ========================================================================
   ;; Debuggers and Profiling Tools
   ;; ========================================================================
   "gdb"                    ; GNU Debugger
   "lldb"                   ; LLVM Debugger
   "valgrind"               ; Memory debugging and profiling
   "perf"                   ; Linux profiling with performance counters
   "strace"                 ; System call tracer
   "ltrace"                 ; Library call tracer
   "rr"                     ; Record and replay debugger

   ;; ========================================================================
   ;; LSP (Language Server Protocol) Servers
   ;; ========================================================================
   "clangd"                 ; C/C++/Objective-C language server
   "rust-analyzer"          ; Rust language server
   "gopls"                  ; Go language server
   "python-language-server" ; Python language server (pyright via pip recommended)
   "typescript"             ; TypeScript and JavaScript language server
   "texlab"                 ; LaTeX language server
   "nil"                    ; Nix language server

   ;; ========================================================================
   ;; Build and Compilation Support
   ;; ========================================================================
   "binutils"               ; Binary utilities (ld, as, nm, objdump, etc.)
   "gcc"                    ; GNU C Compiler (base compiler)
   "gfortran"               ; GNU Fortran Compiler
   "ccls"                   ; C/C++ language server using clang

   ;; ========================================================================
   ;; Version Control and Diff Tools
   ;; ========================================================================
   "git"                    ; Distributed version control
   "git-lfs"                ; Git Large File Storage
   "mercurial"              ; Distributed version control
   "diffutils"              ; GNU diff utilities
   "patch"                  ; GNU patch utility

   ;; ========================================================================
   ;; Documentation and Source Tools
   ;; ========================================================================
   "ctags"                  ; Generate tag files for source navigation
   "universal-ctags"        ; Universal Ctags (improved ctags)
   "cscope"                 ; Code browser and search tool
   "doxygen"                ; Documentation generator

   ;; ========================================================================
   ;; Code Quality and Testing
   ;; ========================================================================
   "shellcheck"             ; Shell script static analyzer
   "hadolint"               ; Dockerfile linter
   "yamllint"               ; YAML linter
   "pylint"                 ; Python code analyzer

   ;; ========================================================================
   ;; System Libraries and Headers
   ;; ========================================================================
   "glibc"                  ; GNU C Library
   "linux-libre-headers"    ; Linux kernel headers
   "libffi"                 ; Foreign function interface library
   "openssl"                ; Secure Sockets Layer and cryptography libraries

   ;; ========================================================================
   ;; Utilities
   ;; ========================================================================
   "gdb-doc"                ; GDB documentation
   "man-pages"              ; Linux man pages
   "texinfo"                ; GNU documentation format

   ))

;; ========================================================================
;; Usage Notes
;; ========================================================================
;;
;; Install all development tools:
;;   guix package -m manifest-dev.scm
;;
;; Create a temporary development environment:
;;   guix shell -m manifest-dev.scm
;;
;; Create a development environment for C/C++ projects:
;;   guix shell -m manifest-dev.scm -- bash
;;
;; Install only specific packages:
;;   guix package -m manifest-dev.scm -A gcc clang rust
;;
;; List all packages in the manifest:
;;   guix package -m manifest-dev.scm -A
;;
;; Some additional LSP servers may be better installed via language-specific
;; package managers (pip, cargo, npm, etc.) for the latest versions:
;;
;;   # Python
;;   pip install pyright pylint black isort
;;
;;   # JavaScript/TypeScript
;;   npm install -g typescript typescript-language-server
;;
;;   # Rust
;;   cargo install rust-analyzer
;;
;;   # Other useful tools
;;   pip install black isort flake8 mypy
;;
;; ========================================================================
