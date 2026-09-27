### 🧭 PATH Configuration (STRUCTURED)

# Base paths (system lowest priority)
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Homebrew (Apple Silicon)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# User binaries
export PATH="$HOME/bin:$HOME/.config/lazygit:$HOME/.console-ninja/.bin:$PATH"

export HOME="/Users/harrison"

# -----------------------------

### 🚀 NVM Setup (PRIMARY CONTROL)

export NVM_DIR="/opt/homebrew/opt/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Optional: force default version (better than hardcoding PATH)
nvm use 24 >/dev/null 2>&1

# -----------------------------

### 🧠 Environment Setup

export XDG_CONFIG_HOME="$HOME/.config"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export TERM="xterm-256color"

# memories.sh data directory (override default ~/.config/memories/)
export MEMORIES_DATA_DIR="$HOME/.config/opencode/memory/db"

# Source local-only secrets (gitignored)
[ -f "$XDG_CONFIG_HOME/.env.local" ] && source "$XDG_CONFIG_HOME/.env.local"

# -----------------------------

### ⚡ Deduplicate PATH (IMPORTANT)

typeset -U path

# -----------------------------

### ⚙️ Zoxide

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# -----------------------------

### 🚀 Completion System

autoload -U compinit
compinit
bindkey '^I' complete-word

# -----------------------------

### 📝 Editor

if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
  export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
  export VISUAL="nvim"
  export EDITOR="nvim"
fi

# -----------------------------

### ✨ Aliases

alias ls="eza --icons=always -1 --group-directories-first --git-ignore --sort=name"

# -----------------------------

### 🌟 Starship

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# -----------------------------

### 🎨 Zsh Plugins

if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# -----------------------------

### 🔊 Fix Audio

alias fixaudio="sudo killall coreaudiod"

export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity IDE
export PATH="/Users/harrison/.antigravity-ide/antigravity-ide/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/harrison/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Added by Antigravity CLI installer
export PATH="/Users/harrison/.local/bin:$PATH"

# Shared packages
alias shared-packages="node $HOME/Downloads/shared-packages/dist/cli.js"

# Google alies
alias google='() { open "https://www.google.com/search?q=$(printf "%s" "$*" | sed "s/ /+/g")"; }'

# Auto-attach/create main tmux session
if command -v tmux >/dev/null 2>&1 && [[ -z "$TMUX" ]]; then
  tmux new-session -A -s main
fi

# Connect to a remote and enter its tmux with this machine's key contract applied:
# C-a as the prefix on both layers, Ctrl+h/j/k/l forwarded to the far-end editor,
# and a teal REMOTE badge so the two nesting levels are never confused. The remote
# must have this repo's tmux/remote-tmux.conf in place.
#
# The three steps exist because each covers a case the others cannot:
#   1. -f is read only at server START, so a cold remote (no tmux yet) must be
#      created with the config already in place. Harmless no-op when a server is
#      already up, where -f would otherwise be ignored.
#   2. source-file then applies the config to an ALREADY-running server. Verified
#      idempotent, so re-connecting does not accumulate state.
#   3. create-or-attach, so a second connection rejoins instead of nesting deeper.
# Without step 1 a cold remote gets a stock bar; without step 2 a warm one does.
#
# The remote command stays on one line deliberately. A `\` continuation would NOT
# work here: inside single quotes zsh passes the backslash and the newline through
# literally (verified), so the string would reach the remote altered rather than
# verbatim, and the quoting discipline below is what keeps $1 out of it. The --
# before "$1" is the complementary guard: the quoting keeps $1 out of the remote
# payload, and the -- keeps it from being read as an option instead of a host.
tssh() {
  ssh -t -- "$1" 'tmux -f ~/.config/tmux/remote-tmux.conf new-session -d -s main 2>/dev/null; tmux source-file ~/.config/tmux/remote-tmux.conf; tmux new-session -A -s main'
}

# Youtube alies
yt() {
  open "https://www.youtube.com/results?search_query=${(j:+:)@}"
}

# Github
github() {
  open "https://github.com/search?q=${(j:+:)@}"
}

cg() {
  open "https://chatgpt.com/?q=${(j:+:)@}"
}

export IP="192.168.1.5"
#

