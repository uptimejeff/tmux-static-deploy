#!/bin/bash

set -euo pipefail

BIN_DIR="/usr/local/macadmin/bin"
TMUX_BIN="$BIN_DIR/tmux"
EXPECTED_VERSION="3.5a"
DOWNLOAD_URL="https://github.com/uptimejeff/tmux-static-deploy/releases/download/v1.0.0/tmux-macos.tar.gz"

# Create the installation directory
mkdir -p "$BIN_DIR"

# Check if tmux is already installed and at the correct version
if [[ -x "$TMUX_BIN" ]] && "$TMUX_BIN" -V | grep -q "$EXPECTED_VERSION"; then
  echo "✅ tmux version $EXPECTED_VERSION is already installed at $TMUX_BIN"
  exit 0
fi

# Download and install tmux
echo "Downloading tmux..."
curl -fsSL "$DOWNLOAD_URL" -o /tmp/tmux.tar.gz
tar -xzf /tmp/tmux.tar.gz -C "$BIN_DIR"
chmod +x "$TMUX_BIN"
rm /tmp/tmux.tar.gz

# Validate the installation
if "$TMUX_BIN" -V | grep -q "$EXPECTED_VERSION"; then
  echo "✅ tmux version $EXPECTED_VERSION installed successfully at $TMUX_BIN"
else
  echo "❌ tmux installation failed or wrong version."
  exit 1
fi

# Add the installation directory to /etc/paths if it's not already there
if ! grep -q "^$BIN_DIR$" /etc/paths; then
  echo "Adding $BIN_DIR to /etc/paths"
  echo "$BIN_DIR" | sudo tee -a /etc/paths
fi

echo "✅ tmux installation complete."