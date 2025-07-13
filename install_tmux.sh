#!/bin/bash

set -euo pipefail

BIN_DIR="/usr/local/macadmin/bin"
SHARE_DIR="/usr/local/macadmin/share"
TMUX_BIN="$BIN_DIR/tmux"
EXPECTED_VERSION="3.5a"
DOWNLOAD_URL="https://github.com/uptimejeff/tmux-static-deploy/releases/download/v1.1.0/tmux-macos-portable.tar.gz"

# --- Task 1: Ensure tmux is installed ---

# Check if tmux is NOT installed or is the wrong version
if ! [[ -x "$TMUX_BIN" ]] || ! "$TMUX_BIN" -V | grep -q "$EXPECTED_VERSION"; then
  echo "Installing tmux version $EXPECTED_VERSION..."
  
  # Create the installation directories
  mkdir -p "$BIN_DIR" "$SHARE_DIR"

  # Create a temporary directory for extraction and ensure it's cleaned up on exit
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TMP_DIR"' EXIT

  # Download and extract the archive
  curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/tmux.tar.gz"
  tar -xzf "$TMP_DIR/tmux.tar.gz" -C "$TMP_DIR"

  # Move the contents to the final destination
  mv "$TMP_DIR"/bin/* "$BIN_DIR/"
  mv "$TMP_DIR"/share/* "$SHARE_DIR/"

  # Set executable permissions
  chmod +x "$TMUX_BIN"

  # Validate the installation
  if "$TMUX_BIN" -V | grep -q "$EXPECTED_VERSION"; then
    echo "✅ tmux version $EXPECTED_VERSION installed successfully."
  else
    echo "❌ tmux installation failed or wrong version."
    exit 1
  fi
else
  echo "✅ tmux is already installed and up to date."
fi

# --- Task 2: Ensure /etc/paths is configured ---

if ! grep -q "^$BIN_DIR$" /etc/paths; then
  echo "Adding $BIN_DIR to /etc/paths..."
  echo "$BIN_DIR" | tee -a /etc/paths
  echo "✅ /etc/paths updated. Please open a new terminal session to use the tmux command."
else
  echo "✅ /etc/paths is already configured correctly."
fi

echo "
Installation check complete."