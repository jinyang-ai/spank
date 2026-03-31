# AI Agent Installation Guide

> **For Claude Code, Cursor, Codex, Aider, Windsurf, or any AI coding assistant**
>
> When user says "install spank" - run these commands. User only needs to enter their password once.

## Quick Install (Copy-Paste Ready)

Run these commands in sequence. The user will be prompted for their password during `sudo`:

```bash
# 1. Check Apple Silicon (REQUIRED)
[[ $(uname -m) == "arm64" ]] || { echo "ERROR: Requires Apple Silicon Mac (M1/M2/M3/M4)"; exit 1; }

# 2. Clone and build
cd ~/Desktop
rm -rf spank 2>/dev/null
git clone https://github.com/jinyang-ai/spank.git
cd spank
./build.sh

# 3. Install app
rm -rf /Applications/Spank.app
cp -R build/Spank.app /Applications/
xattr -cr /Applications/Spank.app

# 4. Install daemon (requires password)
sudo ./install-simple.sh

# 5. Launch
open /Applications/Spank.app

# 6. Verify
sleep 2
pgrep -fl "spank --custom" && echo "✅ Daemon running" || echo "❌ Daemon not running"
pgrep -fl SpankApp && echo "✅ App running" || echo "❌ App not running"
```

## What to Tell User After Install

> "Done! You should see a 🍑 peach in your menu bar. Give your MacBook a **hard slap** to test it! 
> 
> Click the peach to change sounds or adjust sensitivity."

---

## Troubleshooting

### "swiftc: command not found"
```bash
xcode-select --install
# Wait for install, then re-run ./build.sh
```

### App won't open / "damaged" error
```bash
xattr -cr /Applications/Spank.app
```

### No sound when slapping
```bash
# Check daemon
pgrep -fl "spank --custom"

# Check sounds folder has files
ls -la /Users/Shared/spank-sounds/

# If empty, copy sounds manually
sudo cp /Applications/Spank.app/Contents/Resources/sounds/*.mp3 /Users/Shared/spank-sounds/
```

### Can't see 🍑 in menu bar
- Hold ⌘ and drag menu bar icons to make space
- Check for overflow (« or ...) on left side

---

## Uninstall

```bash
sudo launchctl unload /Library/LaunchDaemons/com.aj.spank.plist
sudo rm /Library/LaunchDaemons/com.aj.spank.plist
sudo rm /usr/local/bin/spank
rm -rf /Applications/Spank.app
rm -rf /Users/Shared/spank-sounds
rm -rf ~/Desktop/spank
```

---

## How It Works

- **spank binary**: Uses Apple Silicon accelerometer to detect physical impacts
- **LaunchDaemon**: Runs in background, plays sound on slap detection  
- **Menu bar app**: Lets user pick sounds, adjust threshold, start/stop
- **Volume scaling**: Soft taps = quiet, hard slaps = loud (enabled by default)

## Requirements

- macOS 13+ (Ventura or later)
- Apple Silicon (M1/M2/M3/M4) - Intel Macs don't have accelerometer
- Xcode Command Line Tools (for building)
