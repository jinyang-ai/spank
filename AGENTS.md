# AI Agent Installation Guide

> **For Claude Code, Cursor, Codex, Aider, Windsurf, or any AI coding assistant**
>
> Follow these steps exactly to install Spank on the user's Mac.

## Pre-flight Checks

Before starting, verify:

```bash
# Check macOS version (needs 13+)
sw_vers -productVersion

# Check for Apple Silicon (must show arm64)
uname -m

# Should output: arm64
# If it shows x86_64, STOP - Intel Macs are not supported
```

If Intel Mac detected, inform the user:
> "Spank requires Apple Silicon (M1/M2/M3/M4). Intel Macs don't have the required accelerometer."

---

## Installation Steps

### Step 1: Clone the repository

```bash
cd ~/Desktop
git clone https://github.com/jinyang-ai/spank.git
cd spank
```

### Step 2: Build the app

```bash
./build.sh
```

Expected output:
```
Building Spank...
Compiling...
Copying sounds...
build/Spank.app: replacing existing signature
```

### Step 3: Install to Applications

```bash
# Remove old version if exists
rm -rf /Applications/Spank.app

# Copy new build
cp -R build/Spank.app /Applications/

# Remove Gatekeeper quarantine (IMPORTANT - app is unsigned)
xattr -cr /Applications/Spank.app
```

### Step 4: Install the background service

This requires sudo (user will need to enter their password):

```bash
sudo ./install-simple.sh
```

The script does:
1. Copies spank binary to `/usr/local/bin/`
2. Creates `/Users/Shared/spank-sounds/` directory
3. Copies default sound to that directory
4. Installs LaunchDaemon to `/Library/LaunchDaemons/com.aj.spank.plist`
5. Loads the daemon (starts immediately)

### Step 5: Launch the app

```bash
open /Applications/Spank.app
```

### Step 6: Verify installation

```bash
# Check if spank daemon is running
pgrep -fl "spank --custom"

# Check if menu bar app is running
pgrep -fl SpankApp

# Both should return process IDs
```

### Step 7: Tell the user to test

> "Installation complete! You should see a 🍑 peach emoji in your menu bar. Give your MacBook a **hard slap** on the side or palm rest to test it!"

---

## Post-Installation Info for User

After successful installation, inform the user:

1. **Menu bar**: Click 🍑 to access settings
2. **Start/Stop**: Toggle slap detection without password
3. **Sounds**: Pick from bundled sounds (more can be added)
4. **Threshold**: Adjust how hard you need to slap (default 0.8g)
5. **Auto-start**: App and daemon both start on boot

---

## Troubleshooting

### Build fails with "swiftc: command not found"

```bash
# Install Xcode Command Line Tools
xcode-select --install
```

### App won't open - "damaged" or "unverified" error

```bash
xattr -cr /Applications/Spank.app
```

### No sound when slapping

1. Check daemon is running: `pgrep -fl "spank --custom"`
2. Check sounds exist: `ls /Users/Shared/spank-sounds/`
3. If empty, copy sound: `sudo cp build/Spank.app/Contents/Resources/sounds/*.mp3 /Users/Shared/spank-sounds/`

### Can't see 🍑 in menu bar

The icon might be hidden. Tell user to:
- Hold ⌘ and drag other menu bar icons to make space
- Look for overflow indicator (« or ...) on left side of menu bar

---

## Uninstallation

If user wants to uninstall:

```bash
# Stop and remove daemon
sudo launchctl unload /Library/LaunchDaemons/com.aj.spank.plist
sudo rm /Library/LaunchDaemons/com.aj.spank.plist

# Remove app
rm -rf /Applications/Spank.app

# Remove sounds folder
rm -rf /Users/Shared/spank-sounds

# Remove spank binary
sudo rm /usr/local/bin/spank

# Remove from login items (optional - user can do manually)
osascript -e 'tell application "System Events" to delete login item "Spank"' 2>/dev/null
```

---

## Summary Checklist

- [ ] Verified Apple Silicon Mac
- [ ] Cloned repo
- [ ] Built app with `./build.sh`
- [ ] Copied to `/Applications/`
- [ ] Removed quarantine with `xattr -cr`
- [ ] Ran `sudo ./install-simple.sh`
- [ ] Launched app with `open /Applications/Spank.app`
- [ ] Verified 🍑 appears in menu bar
- [ ] Told user to slap their MacBook to test
