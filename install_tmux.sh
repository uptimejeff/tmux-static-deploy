#!/bin/bash

set -euo pipefail

BIN_DIR="/usr/local/macadmin/bin"
TMUX_BIN="$BIN_DIR/tmux"
EXPECTED_VERSION="3.5a"
DOWNLOAD_URL="https://github.com/uptimejeff/tmux-static-deploy/releases/download/v1.1.0/tmux-macos-portable.tar.gz"

# Create the installation directory
mkdir -p "$BIN_DIR" "/usr/local/macadmin/share"

# Check if tmux is already installed and at the correct version
if [[ -x "$TMUX_BIN" ]] && "$TMUX_BIN" -V | grep -q "$EXPECTED_VERSION"; then
  echo "✅ tmux version $EXPECTED_VERSION is already installed at $TMUX_BIN"
  exit 0
fi

# Download and install tmux
echo "Downloading tmux..."

# Create a temporary directory for extraction
TMP_DIR=$(mktemp -d)

# Download and extract the archive
curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/tmux.tar.gz"
tar -xzf "$TMP_DIR/tmux.tar.gz" -C "$TMP_DIR"

# Move the contents to the final destination
# This handles the nested directory structure
mv "$TMP_DIR"/bin/* "$BIN_DIR/"
mv "$TMP_DIR"/share/* "/usr/local/macadmin/share/"

# Set executable permissions
chmod +x "$TMUX_BIN"

# Clean up the temporary directory
rm -rf "$TMP_DIR"

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