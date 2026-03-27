# 🍑 Spank - Installation Guide

**Slap your MacBook, it talks back.**

## Requirements

- MacBook with Apple Silicon (M1 Pro, M2, M3, M4, or newer)
- macOS 13 or later

---

## Installation (2 minutes)

### Step 1: Download & Open

1. Download `Spank.dmg`
2. Double-click to open it
3. Drag `Spank.app` to your **Applications** folder

### Step 2: Run the Installer

Open **Terminal** (search for it in Spotlight with Cmd+Space) and paste:

```bash
sudo /Applications/Spank.app/Contents/Resources/install-simple.sh
```

Enter your password when prompted. You'll see:

```
🍑 Spank Installer
===================

→ Installing spank binary...
→ Setting up sounds...
→ Installing background service...
→ Starting spank...

✅ Done!

Spank is now running.
Give your MacBook a HARD slap!
```

### Step 3: Test It!

Give your MacBook a **hard slap** on the palm rest area. You should hear the sound!

---

## Using the App

Look for the **🍑** peach emoji in your menu bar (top right of screen).

Click it to:
- **Start/Stop** the slap detection
- **Adjust threshold** (higher = needs harder slap)
- **Adjust cooldown** (time between sounds)
- **Test the sound**

---

## Troubleshooting

### Nothing happens when I slap?

1. Make sure you're slapping **hard** (the threshold is set high to avoid false triggers)
2. Check the 🍑 menu - is it showing "Running"?
3. Try lowering the threshold slider

### How do I uninstall?

Run in Terminal:
```bash
sudo launchctl unload /Library/LaunchDaemons/com.aj.spank.plist
sudo rm /Library/LaunchDaemons/com.aj.spank.plist
sudo rm /usr/local/bin/spank
rm -rf /Applications/Spank.app
```

---

## How It Works

Spank uses your MacBook's built-in accelerometer to detect physical impacts. When you slap it hard enough (above the threshold), it plays the sound.

The detection runs as a background service, so it works even when the app isn't open.

---

Made with 🍑 by AJ
