# AI Agent Installation Guide

> **For Claude Code, Cursor, Codex, Aider, Windsurf, or any AI coding assistant**
>
> When user says "install spank" - run these commands. User only needs to enter their password once.
> 
> **~15MB download. No Xcode required.**

## Quick Install (Copy-Paste Ready)

Run these commands in sequence. The user will be prompted for their password during `sudo`:

```bash
# 1. Check Apple Silicon (REQUIRED)
[[ $(uname -m) == "arm64" ]] || { echo "ERROR: Requires Apple Silicon Mac (M1/M2/M3/M4)"; exit 1; }

# 2. Download pre-built app
curl -L https://github.com/jinyang-ai/spank/releases/download/v1.0.0/Spank.zip -o /tmp/Spank.zip

# 3. Unzip and install
unzip -o /tmp/Spank.zip -d /tmp
rm -rf /Applications/Spank.app
cp -R /tmp/Spank.app /Applications/
xattr -cr /Applications/Spank.app

# 4. Install daemon (requires password)
sudo /Applications/Spank.app/Contents/Resources/install-simple.sh

# 5. Launch
open /Applications/Spank.app

# 6. Cleanup & verify
rm -f /tmp/Spank.zip
rm -rf /tmp/Spank.app
sleep 2
pgrep -fl "spank --custom" && echo "✅ Daemon running" || echo "❌ Daemon not running"
pgrep -fl SpankApp && echo "✅ App running" || echo "❌ App not running"
```

## One-liner version

```bash
curl -L https://github.com/jinyang-ai/spank/releases/download/v1.0.0/Spank.zip -o /tmp/Spank.zip && unzip -o /tmp/Spank.zip -d /tmp && cp -R /tmp/Spank.app /Applications/ && xattr -cr /Applications/Spank.app && sudo /Applications/Spank.app/Contents/Resources/install-simple.sh && open /Applications/Spank.app
```

## What to Tell User After Install

> "Done! You should see a 🍑 peach in your menu bar. Give your MacBook a **hard slap** to test it! 
> 
> Click the peach to change sounds or adjust sensitivity."

---

## Troubleshooting

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
- **No Xcode needed** - uses pre-built binary
