#!/bin/sh

# ─── Colors ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { printf "${YELLOW}[INFO]${NC}  %s\n" "$1"; }
ok()   { printf "${GREEN}[OK]${NC}    %s\n" "$1"; }

# Simple Y/n prompt, default = Y on empty input
ask_install() {
  while :; do
    printf "%s (Y/n): " "$1"
    IFS= read -r answer
    case "$answer" in
      [Yy]|"") return 0 ;;
      [Nn])    return 1 ;;
      *)       printf "Please answer y or n.\n" ;;
    esac
  done
}

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ─── 1. Homebrew ──────────────────────────────────────────────────────────────
if command -v brew > /dev/null 2>&1; then
  ok "Homebrew already installed ($(brew --version | head -1))"
else
  info "Homebrew not found."
  if ask_install "Install Homebrew"; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ok "Homebrew installed"
  else
    info "Skipped Homebrew installation"
  fi
fi

# ─── 2. Cursor ────────────────────────────────────────────────────────────────
if command -v cursor > /dev/null 2>&1 || [ -d "/Applications/Cursor.app" ]; then
  ok "Cursor already installed"
else
  info "Cursor not found."
  if command -v brew > /dev/null 2>&1; then
    if ask_install "Install Cursor via Homebrew cask"; then
      info "Installing Cursor..."
      brew install --cask cursor
      ok "Cursor installed"
    else
      info "Skipped Cursor installation"
    fi
  else
    info "Homebrew is required to install Cursor, but is not available. Skipping."
  fi
fi

# ─── 3. iTerm2 ────────────────────────────────────────────────────────────────
if brew list --cask iterm2 > \dev\null 2>&1; then
  ok "iTerm2 already installed"
else
  info "iTerm2 not found."
  if command -v brew > /dev/null 2>&1 && ask_install "Install iTerm2 via Homebrew cask"; then
    info "Installing iTerm2..."
    brew install --cask iterm2
    ok "iTerm2 installed"
  else
    info "Skipped iTerm2 installation"
  fi
fi

# ─── 4. Oh My Zsh + Zsh ───────────────────────────────────────────────────────
if command -v zsh > /dev/null 2>&1 && [ -d "$HOME/.oh-my-zsh" ]; then
  ok "zsh + Oh My Zsh already installed ($(zsh --version))"
else
  info "zsh and/or Oh My Zsh not found."
  if ask_install "Install zsh + Oh My Zsh"; then
    info "Installing zsh via Oh My Zsh installer..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    ok "zsh + Oh My Zsh installed"
  else
    info "Skipped zsh + Oh My Zsh installation"
  fi
fi

# ─── 5. zsh-autosuggestions ───────────────────────────────────────────────────
if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  ok "zsh-autosuggestions already installed"
else
  info "zsh-autosuggestions not found."
  if ask_install "Install zsh-autosuggestions plugin"; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions \
      "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    ok "zsh-autosuggestions installed"
  else
    info "Skipped zsh-autosuggestions installation"
  fi
fi

# ─── 6. zsh-syntax-highlighting ───────────────────────────────────────────────
if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  ok "zsh-syntax-highlighting already installed"
else
  info "zsh-syntax-highlighting not found."
  if ask_install "Install zsh-syntax-highlighting plugin"; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
      "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    ok "zsh-syntax-highlighting installed"
  else
    info "Skipped zsh-syntax-highlighting installation"
  fi
fi

# ─── 7. Copy .zshrc ───────────────────────────────────────────────────────────
info ".zshrc will overwrite any existing file."
if ask_install "Copy $SCRIPT_DIR/zshrc to \$HOME/.zshrc"; then
  info "Copying .zshrc to $HOME/.zshrc..."
  cp "$SCRIPT_DIR/zshrc" "$HOME/.zshrc"
  ok ".zshrc copied"
else
  info "Skipped copying .zshrc"
fi

printf "\n${GREEN}All done!${NC} Restart your shell or run: source ~/.zshrc\n"

