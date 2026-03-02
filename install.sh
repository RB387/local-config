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

# ─── 3. Claude CLI ────────────────────────────────────────────────────────────
claude_bin="$HOME/.local/bin/claude"
if command -v claude > /dev/null 2>&1 || [ -x "$claude_bin" ]; then
  ok "Claude CLI already installed"
else
  info "Claude CLI not found."
  if ask_install "Install Claude CLI"; then
    info "Installing Claude CLI..."
    curl -fsSL https://claude.ai/install.sh | bash
    ok "Claude CLI installed (binary at $claude_bin)"
    info "Ensure \$HOME/.local/bin is in your PATH (see step 9: copy .zshrc)"
  else
    info "Skipped Claude CLI installation"
  fi
fi

# ─── 4. Claude Desktop ────────────────────────────────────────────────────────
if brew list --cask claude > /dev/null 2>&1 || [ -d "/Applications/Claude.app" ]; then
  ok "Claude Desktop already installed"
else
  info "Claude Desktop not found."
  if command -v brew > /dev/null 2>&1 && ask_install "Install Claude Desktop via Homebrew cask"; then
    info "Installing Claude Desktop..."
    brew install --cask claude
    ok "Claude Desktop installed"
  else
    info "Skipped Claude Desktop installation"
  fi
fi

# ─── 5. iTerm2 ────────────────────────────────────────────────────────────────
iterm_just_installed=0
if brew list --cask iterm2 > /dev/null 2>&1; then
  ok "iTerm2 already installed"
else
  info "iTerm2 not found."
  if command -v brew > /dev/null 2>&1 && ask_install "Install iTerm2 via Homebrew cask"; then
    info "Installing iTerm2..."
    brew install --cask iterm2
    ok "iTerm2 installed"
    iterm_just_installed=1
  else
    info "Skipped iTerm2 installation"
  fi
fi
if [ "$iterm_just_installed" = 1 ]; then
  info "Import iTerm2 profiles: Profiles → Open Profiles → Edit Profiles → Other Actions → Import JSON Profiles"
  info "Select: $SCRIPT_DIR/iterm/Default.json"
  printf "Press Enter when done..."
  read -r _
fi

# ─── 6. Oh My Zsh + Zsh ───────────────────────────────────────────────────────
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

# ─── 7. zsh-autosuggestions ───────────────────────────────────────────────────
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

# ─── 8. zsh-syntax-highlighting ───────────────────────────────────────────────
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

# ─── 9. Copy .zshrc ───────────────────────────────────────────────────────────
info ".zshrc will overwrite any existing file."
if ask_install "Copy $SCRIPT_DIR/zshrc to \$HOME/.zshrc"; then
  info "Copying .zshrc to $HOME/.zshrc..."
  cp "$SCRIPT_DIR/zshrc" "$HOME/.zshrc"
  ok ".zshrc copied"
else
  info "Skipped copying .zshrc"
fi

# ─── 10. Git configuration ───────────────────────────────────────────────────
if command -v git > /dev/null 2>&1; then
  git_name=$(git config --global user.name 2>/dev/null)
  git_email=$(git config --global user.email 2>/dev/null)
  if [ -n "$git_name" ] && [ -n "$git_email" ]; then
    ok "Git already configured (user.name=$git_name, user.email=$git_email)"
  else
    info "Git user.name and/or user.email not set."
    if ask_install "Configure git user.name and user.email"; then
      printf "  git user.name: "
      IFS= read -r git_name
      printf "  git user.email: "
      IFS= read -r git_email
      if [ -n "$git_name" ]; then
        git config --global user.name "$git_name"
        ok "git config --global user.name set"
      fi
      if [ -n "$git_email" ]; then
        git config --global user.email "$git_email"
        ok "git config --global user.email set"
      fi
    else
      info "Skipped git configuration"
    fi
  fi
else
  info "Git not found. Install git first to configure it."
fi

printf "\n${GREEN}All done!${NC} Restart your shell or run: source ~/.zshrc\n"

