#!/usr/bin/env bash
# =============================================================================
# Dotfiles Setup Script
# Creates directories, symlinks configs, and installs GeistMono Nerd Font
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"
FONT_DIR="$HOME/.local/share/fonts"

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; }

# ---------------------------------------------------------------------------
# 1. Create config directories
# ---------------------------------------------------------------------------
info "Creating config directories..."
for dir in sway foot fsel waybar; do
    mkdir -p "$CONFIG_DIR/$dir"
done

# ---------------------------------------------------------------------------
# 2. Symlink dotfiles
# ---------------------------------------------------------------------------
info "Symlinking dotfiles..."

link() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        warn "Already symlinked: $dest"
    elif [ -e "$dest" ]; then
        error "File exists (not a symlink): $dest — skipping"
    else
        ln -s "$src" "$dest"
        info "Linked: $dest -> $src"
    fi
}

link "$DOTFILES_DIR/sway/config"              "$CONFIG_DIR/sway/config"
link "$DOTFILES_DIR/sway/walls"              "$CONFIG_DIR/sway/walls"
link "$DOTFILES_DIR/foot/foot.ini"            "$CONFIG_DIR/foot/foot.ini"
link "$DOTFILES_DIR/fsel/config.toml"         "$CONFIG_DIR/fsel/config.toml"
link "$DOTFILES_DIR/waybar/config"            "$CONFIG_DIR/waybar/config"
link "$DOTFILES_DIR/waybar/style.css"         "$CONFIG_DIR/waybar/style.css"

# ---------------------------------------------------------------------------
# 3. Install GeistMono Nerd Font
# ---------------------------------------------------------------------------
FONT_NAME="GeistMono"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.tar.xz"

if fc-list :family | grep -qi "geist mono nerd font"; then
    info "GeistMono Nerd Font already installed — skipping"
else
    info "Installing GeistMono Nerd Font..."
    mkdir -p "$FONT_DIR"

    TMPDIR=$(mktemp -d)
    ARCHIVE="$TMPDIR/${FONT_NAME}.tar.xz"

    info "Downloading font..."
    curl -sL "$FONT_URL" -o "$ARCHIVE"

    info "Extracting font..."
    tar -xf "$ARCHIVE" -C "$TMPDIR"

    info "Copying fonts to $FONT_DIR..."
    cp "$TMPDIR"/*.ttf "$FONT_DIR/" 2>/dev/null || cp "$TMPDIR"/*.otf "$FONT_DIR/" 2>/dev/null || {
        error "No font files found in archive"
        rm -rf "$TMPDIR"
        exit 1
    }

    rm -rf "$TMPDIR"

    info "Rebuilding font cache..."
    fc-cache -f "$FONT_DIR" 2>/dev/null || fc-cache -f

    if fc-list :family | grep -qi "geist mono nerd font"; then
        info "GeistMono Nerd Font installed successfully"
    else
        warn "Font installed but not yet detected — try logging out and back in"
    fi
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
info "Dotfiles setup complete!"
info "Start sway with: sway"
