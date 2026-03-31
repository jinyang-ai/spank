#!/bin/bash
# Spank Installer - Run once with sudo
set -e

echo ""
echo "  🍑 Spank Installer"
echo "  ==================="
echo ""

if [[ $EUID -ne 0 ]]; then
   echo "Run with: sudo ./install-simple.sh"
   exit 1
fi

# Remove quarantine attribute from app
echo "→ Removing quarantine..."
xattr -cr /Applications/Spank.app 2>/dev/null || true

# Find app bundle
APP_BUNDLE="/Applications/Spank.app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -d "$APP_BUNDLE" ]]; then
    # Check if we're inside the app bundle
    if [[ "$SCRIPT_DIR" == *"Spank.app/Contents/Resources"* ]]; then
        APP_BUNDLE="${SCRIPT_DIR%/Contents/Resources}"
    fi
fi

RESOURCES="$APP_BUNDLE/Contents/Resources"

# Install spank binary
echo "→ Installing spank binary..."
if [[ -f "$RESOURCES/spank" ]]; then
    cp "$RESOURCES/spank" /usr/local/bin/spank
elif [[ -f /tmp/spank ]]; then
    cp /tmp/spank /usr/local/bin/spank
else
    echo "  Downloading..."
    curl -sL "https://github.com/taigrr/spank/releases/download/v1.2.5/spank_1.2.5_darwin_arm64.tar.gz" | tar xz -C /usr/local/bin/
fi
chmod +x /usr/local/bin/spank

# Setup sounds folder with default sound
echo "→ Setting up sounds..."
mkdir -p /Users/Shared/spank-sounds
chmod 777 /Users/Shared/spank-sounds

# Copy default sound (ma-ka-bhosda-aag)
if [[ -f "$RESOURCES/sounds/ma-ka-bhosda-aag.mp3" ]]; then
    cp "$RESOURCES/sounds/ma-ka-bhosda-aag.mp3" /Users/Shared/spank-sounds/sound.mp3
    chmod 666 /Users/Shared/spank-sounds/sound.mp3
elif [[ -d "$RESOURCES/sounds" ]]; then
    FIRST_SOUND=$(ls "$RESOURCES/sounds/"*.mp3 2>/dev/null | head -1)
    if [[ -n "$FIRST_SOUND" ]]; then
        cp "$FIRST_SOUND" /Users/Shared/spank-sounds/sound.mp3
        chmod 666 /Users/Shared/spank-sounds/sound.mp3
    fi
elif [[ -f "$RESOURCES/sound.mp3" ]]; then
    cp "$RESOURCES/sound.mp3" /Users/Shared/spank-sounds/
    chmod 666 /Users/Shared/spank-sounds/sound.mp3
fi

# Install daemon
echo "→ Installing background service..."
cat > /Library/LaunchDaemons/com.aj.spank.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.aj.spank</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/spank</string>
        <string>--custom</string>
        <string>/Users/Shared/spank-sounds</string>
        <string>--min-amplitude</string>
        <string>0.8</string>
        <string>--cooldown</string>
        <string>2000</string>
        <string>--volume-scaling</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# Start daemon
echo "→ Starting spank..."
launchctl unload /Library/LaunchDaemons/com.aj.spank.plist 2>/dev/null || true
launchctl load /Library/LaunchDaemons/com.aj.spank.plist

echo ""
echo "  ✅ Done!"
echo ""
echo "  Spank is now running."
echo "  Give your MacBook a HARD slap!"
echo ""
