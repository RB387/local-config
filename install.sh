#!/bin/sh

# ─── Colors ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { printf "${YELLOW}[INFO]${NC}  %s\n" "$1"; }
ok()   { printf "${GREEN}[OK]${NC}    %s\n" "$1"; }

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ─── 1. Homebrew ──────────────────────────────────────────────────────────────
if command -v brew > /dev/null 2>&1; then
  ok "Homebrew already installed ($(brew --version | head -1))"
else
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ok "Homebrew installed"
fi

# ─── 2. iTerm2 ────────────────────────────────────────────────────────────────
if brew list --cask iterm2 > /dev/null 2>&1; then
  ok "iTerm2 already installed"
else
  info "Installing iTerm2..."
  brew install --cask iterm2
  ok "iTerm2 installed"
fi

# ─── 3. Oh My Zsh + Zsh ───────────────────────────────────────────────────────
if command -v zsh > /dev/null 2>&1 && [ -d "$HOME/.oh-my-zsh" ]; then
  ok "zsh + Oh My Zsh already installed ($(zsh --version))"
else
  info "Installing zsh via Oh My Zsh installer..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  ok "zsh + Oh My Zsh installed"
fi

# ─── 4. zsh-autosuggestions ───────────────────────────────────────────────────
if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  ok "zsh-autosuggestions already installed"
else
  info "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  ok "zsh-autosuggestions installed"
fi

# ─── 5. zsh-syntax-highlighting ───────────────────────────────────────────────
if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  ok "zsh-syntax-highlighting already installed"
else
  info "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  ok "zsh-syntax-highlighting installed"
fi

# ─── 6. Copy .zshrc ───────────────────────────────────────────────────────────
info "Copying .zshrc to $HOME/.zshrc..."
cp "$SCRIPT_DIR/zshrc" "$HOME/.zshrc"
ok ".zshrc copied"

printf "\n${GREEN}All done!${NC} Restart your shell or run: source ~/.zshrc\n"

