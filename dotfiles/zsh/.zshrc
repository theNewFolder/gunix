# -*- mode: shell-script -*-
# Zsh Configuration with Guix Integration
# Compatible with dwl-guile and Emacs workflow

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE

# Completion
autoload -Uz compinit
compinit

# Key bindings
bindkey -e  # Emacs-style bindings

# Basic options
setopt INTERACTIVE_COMMENTS EXTENDED_GLOB
unsetopt BEEP

# Guix environment setup
if command -v guix &> /dev/null; then
    # Set up Guix profile
    export GUIX_PROFILE="$HOME/.guix-profile"
    [ -f "$GUIX_PROFILE/etc/profile" ] && source "$GUIX_PROFILE/etc/profile"

    # Add Guix to PATH
    export PATH="$HOME/.guix-profile/bin:$HOME/.guix-profile/sbin:$PATH"

    # Set up Guix pkg-config
    [ -d "$HOME/.guix-profile/lib/pkgconfig" ] && \
        export PKG_CONFIG_PATH="$HOME/.guix-profile/lib/pkgconfig:$PKG_CONFIG_PATH"
fi

# Locale setup
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Editor preferences
export EDITOR=emacs
export VISUAL=emacs

# Less options
export LESS='-R -S -X -F'

# Pager for man pages
export PAGER=less

# Aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -1'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias gs='guix search'
alias gi='guix install'
alias gshow='guix show'
alias gshell='guix shell'
alias gupgrade='guix upgrade'
alias gpull='guix pull'

# Useful functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Prompt setup
autoload -Uz prompt_subst
setopt PROMPT_SUBST

# Simple, clean prompt
PROMPT='%F{blue}%n@%m%f %F{cyan}%~%f %# '
RPROMPT='%F{gray}%*%f'

# Initialize keybindings after prompt setup
if [ -n "$KEYMAP" ]; then
    bindkey -e
fi

# Conditional emacs integration (comment out if not needed)
if command -v emacsclient &> /dev/null; then
    alias e='emacsclient -n'
    alias et='emacsclient -t'
fi

# Source local zsh config if it exists
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
