#!/bin/bash
# Spank App Installer
# Run once with: sudo ./install.sh
# After this, the app works without password prompts

set -e

APP_BUNDLE="/Applications/Spank.app"
DAEMON_PLIST="/Library/LaunchDaemons/com.aj.spank-daemon.plist"
CONFIG_FILE="/tmp/spank-config.json"
SPANK_BIN="$APP_BUNDLE/Contents/Resources/spank"

echo "=== Spank Installer ==="
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This installer needs root privileges."
   echo "Run: sudo ./install.sh"
   exit 1
fi

# Check if app is installed
if [[ ! -d "$APP_BUNDLE" ]]; then
    echo "Error: Spank.app not found in /Applications"
    echo "First copy Spank.app to /Applications, then run this installer."
    exit 1
fi

# Check if spank binary exists
if [[ ! -x "$SPANK_BIN" ]]; then
    echo "Error: spank binary not found in app bundle"
    exit 1
fi

# Create initial config
echo "Creating config file..."
cat > "$CONFIG_FILE" << 'EOF'
{
  "running": false,
  "minAmplitude": 0.80,
  "cooldown": 3000,
  "soundsPath": "/Users/Shared/spank-sounds"
}
EOF
chmod 666 "$CONFIG_FILE"

# Create shared sounds directory
echo "Setting up sounds directory..."
mkdir -p /Users/Shared/spank-sounds
chmod 777 /Users/Shared/spank-sounds

# Copy any existing sounds
if [[ -d "$HOME/spank-sounds" ]]; then
    cp -n "$HOME/spank-sounds"/*.mp3 /Users/Shared/spank-sounds/ 2>/dev/null || true
fi

# Create the daemon plist
echo "Installing daemon..."
cat > "$DAEMON_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.aj.spank-daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>
while true; do
    if [[ -f /tmp/spank-config.json ]]; then
        RUNNING=\$(cat /tmp/spank-config.json | grep -o '"running": *[^,}]*' | grep -o 'true\|false')
        if [[ "\$RUNNING" == "true" ]]; then
            if ! pgrep -f "spank --custom" > /dev/null; then
                AMP=\$(cat /tmp/spank-config.json | grep -o '"minAmplitude": *[0-9.]*' | grep -o '[0-9.]*\$')
                COOL=\$(cat /tmp/spank-config.json | grep -o '"cooldown": *[0-9]*' | grep -o '[0-9]*\$')
                SOUNDS=\$(cat /tmp/spank-config.json | grep -o '"soundsPath": *"[^"]*"' | sed 's/"soundsPath": *"//' | sed 's/"\$//')
                $SPANK_BIN --custom "\$SOUNDS" --min-amplitude "\$AMP" --cooldown "\$COOL" &amp;
            fi
        else
            pkill -f "spank --custom" 2>/dev/null || true
        fi
    fi
    sleep 2
done
        </string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/spank-daemon.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/spank-daemon.err</string>
</dict>
</plist>
EOF

# Load the daemon
echo "Starting daemon..."
launchctl unload "$DAEMON_PLIST" 2>/dev/null || true
launchctl load "$DAEMON_PLIST"

echo ""
echo "=== Installation Complete ==="
echo ""
echo "The Spank daemon is now running."
echo "Open Spank.app from your menu bar - no more password prompts!"
echo ""
echo "Sounds folder: /Users/Shared/spank-sounds"
echo "Put your MP3 files there."
echo ""
echo "To uninstall:"
echo "  sudo launchctl unload $DAEMON_PLIST"
echo "  sudo rm $DAEMON_PLIST"
