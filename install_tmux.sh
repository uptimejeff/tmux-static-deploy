#!/bin/bash

set -euo pipefail

BIN_DIR="/usr/local/macadmin/bin"
SHARE_DIR="/usr/local/macadmin/share"
TMUX_BIN="$BIN_DIR/tmux"
EXPECTED_VERSION="3.5a"
DOWNLOAD_URL="https://github.com/uptimejeff/tmux-static-deploy/releases/download/v1.1.0/tmux-macos-portable.tar.gz"

# Create the installation directories
mkdir -p "$BIN_DIR" "$SHARE_DIR"

# Check if tmux is already installed and at the correct version
if [[ -x "$TMUX_BIN" ]] && "$TMUX_BIN" -V | grep -q "$EXPECTED_VERSION"; then
  echo "✅ tmux version $EXPECTED_VERSION is already installed at $TMUX_BIN"
  exit 0
fi

# Download and install tmux
echo "Downloading tmux..."

# Create a temporary directory for extraction and ensure it's cleaned up on exit
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Download and extract the archive
curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/tmux.tar.gz"
tar -xzf "$TMP_DIR/tmux.tar.gz" -C "$TMP_DIR"



# Check for and move contents of bin directory
if [ -d "$TMP_DIR/bin" ]; then
  echo "Moving files from $TMP_DIR/bin to $BIN_DIR"
  mv "$TMP_DIR"/bin/* "$BIN_DIR/"
else
  echo "❌ ERROR: Extracted archive does not contain a 'bin' directory at the expected path."
  exit 1
fi

# Check for and move contents of share directory
if [ -d "$TMP_DIR/share" ]; then
  echo "Moving files from $TMP_DIR/share to $SHARE_DIR"
  mv "$TMP_DIR"/share/* "$SHARE_DIR/"
else
  echo "❌ ERROR: Extracted archive does not contain a 'share' directory at the expected path."
  exit 1
fi

# Set executable permissions
chmod +x "$TMUX_BIN"

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
  echo "$BIN_DIR" | tee -a /etc/paths
fi

echo "✅ tmux installation complete."
