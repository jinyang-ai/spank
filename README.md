# 🍑 Spank

**Slap your MacBook. See what happens.**

A macOS menu bar app that plays a surprise sound when you physically slap your MacBook. Uses the Apple Silicon accelerometer to detect impacts.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue) ![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-M1%2FM2%2FM3%2FM4-orange) ![License](https://img.shields.io/badge/license-MIT-green)

## Requirements

- macOS 13+ (Ventura or later)
- Apple Silicon Mac (M1, M2, M3, M4 - any variant)
- **Intel Macs are NOT supported** (no accelerometer)

## Quick Install (~15MB, No Xcode needed)

### Option 1: Terminal

```bash
curl -L https://github.com/jinyang-ai/spank/releases/download/v1.0.0/Spank.zip -o /tmp/Spank.zip && unzip -o /tmp/Spank.zip -d /tmp && cp -R /tmp/Spank.app /Applications/ && xattr -cr /Applications/Spank.app && sudo /Applications/Spank.app/Contents/Resources/install-simple.sh && open /Applications/Spank.app
```

### Option 2: AI Agent

Tell your AI assistant (Claude Code, Cursor, Windsurf, etc.):
> "Install spank from github.com/jinyang-ai/spank using AGENTS.md"

### Option 3: Website

Visit **[spankithard.vercel.app](https://spankithard.vercel.app)** and follow the instructions.

---

## AI Agent Installation

> **For Claude Code, Cursor, Codex, Aider, or any AI coding assistant**
> 
> If a user shares this repo with you and asks you to install Spank on their Mac, follow the instructions in `AGENTS.md`.

---

## Build from Source (For Developers)

Requires Xcode Command Line Tools.

```bash
# Clone
git clone https://github.com/jinyang-ai/spank.git
cd spank

# Build
./build.sh

# Install
cp -R build/Spank.app /Applications/
xattr -cr /Applications/Spank.app
sudo ./install-simple.sh

# Launch
open /Applications/Spank.app
```

---

## How It Works

1. **spank binary** (from [taigrr/spank](https://github.com/taigrr/spank)) reads the Apple Silicon accelerometer
2. When impact exceeds threshold (default 0.8g), it plays a sound from `/Users/Shared/spank-sounds/`
3. **Spank.app** provides a menu bar UI to control settings and select sounds
4. A **LaunchDaemon** runs the spank binary at boot with root privileges (required for accelerometer access)

---

## Features

- 🍑 **Menu bar app** - lives in your menu bar
- 🔊 **Sound picker** - choose from bundled sounds
- 🎚️ **Adjustable threshold** - control slap sensitivity
- ⏱️ **Cooldown** - prevent rapid-fire triggers
- ⚡ **Auto-start** - runs at boot
- 🆓 **100% free** - no ads, no tracking

---

## Adding Custom Sounds

Drop `.mp3`, `.wav`, or `.m4a` files into:

```
/Users/Shared/spank-sounds/
```

They'll appear in the sound picker immediately.

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

## Project Structure

```
SpankApp/
├── SpankApp/
│   ├── SpankApp.swift      # Main app code (menu bar UI)
│   ├── Info.plist          # App metadata
│   └── sounds/             # Bundled sound files
├── build.sh                # Build script (for developers)
├── install-simple.sh       # Installer (sets up LaunchDaemon)
└── website/                # Distribution website
    └── index.html
```

---

## Troubleshooting

### "Apple cannot verify" or "damaged app" error

The app is unsigned. Run:

```bash
xattr -cr /Applications/Spank.app
```

### Nothing happens when I slap

1. Slap **harder** - threshold is set high to avoid false triggers
2. Check 🍑 menu shows "Running"
3. Lower the threshold in the menu

### Menu bar icon not visible

- Hold ⌘ and drag other icons to make space
- Check the overflow area (« arrow) on left side of menu bar

---

## Credits

- Accelerometer detection: [taigrr/spank](https://github.com/taigrr/spank)
- Built by AJ

---

## License

MIT
