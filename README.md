# 🍑 Spank

**Slap your MacBook. See what happens.**

A macOS menu bar app that plays a surprise sound when you physically slap your MacBook. Uses the Apple Silicon accelerometer to detect impacts.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue) ![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-M1%2FM2%2FM3%2FM4-orange) ![License](https://img.shields.io/badge/license-MIT-green)

## Requirements

- macOS 13+ (Ventura or later)
- Apple Silicon Mac (M1, M2, M3, M4 - any variant)
- **Intel Macs are NOT supported** (different accelerometer)

## Quick Install (For Humans)

Download from **[spank-macos.vercel.app](https://spank-macos.vercel.app)** and follow the instructions.

---

## AI Agent Installation

> **For Claude Code, Cursor, Codex, Aider, or any AI coding assistant**
> 
> If a user shares this repo with you and asks you to install Spank on their Mac, follow the instructions in `AGENTS.md`.

---

## Manual Build from Source

### 1. Clone the repo

```bash
git clone https://github.com/jinyang-ai/spank.git
cd spank
```

### 2. Build the app

```bash
./build.sh
```

This creates `build/Spank.app`

### 3. Install to Applications

```bash
cp -R build/Spank.app /Applications/
xattr -cr /Applications/Spank.app
```

### 4. Install the background service (one-time, requires password)

```bash
sudo ./install-simple.sh
```

### 5. Launch the app

```bash
open /Applications/Spank.app
```

Look for 🍑 in your menu bar!

### 6. Slap your MacBook

Give it a **hard slap** on the side or palm rest. Trust us.

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
SpankApp/sounds/
```

Then rebuild and reinstall the app.

---

## Uninstall

```bash
sudo launchctl unload /Library/LaunchDaemons/com.aj.spank.plist
sudo rm /Library/LaunchDaemons/com.aj.spank.plist
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
├── build.sh                # Build script
├── install-simple.sh       # Installer (sets up LaunchDaemon)
├── spank-daemon.plist      # LaunchDaemon config
└── website/                # Distribution website
    ├── index.html
    └── Spank.dmg
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
