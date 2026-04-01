# 🍑 Spank - Installation Guide

**Slap your MacBook, it talks back.**

## Requirements

- MacBook with Apple Silicon (M1, M2, M3, M4, or newer)
- macOS 13 or later
- **~15MB disk space**
- **No Xcode required**

---

## Quick Install (1 minute)

Open **Terminal** (press `⌘ Space`, type "Terminal", press Enter) and paste:

```bash
curl -L https://github.com/jinyang-ai/spank/releases/download/v1.0.0/Spank.zip -o /tmp/Spank.zip && unzip -o /tmp/Spank.zip -d /tmp && cp -R /tmp/Spank.app /Applications/ && xattr -cr /Applications/Spank.app && sudo /Applications/Spank.app/Contents/Resources/install-simple.sh && open /Applications/Spank.app
```

Enter your password when prompted. Done!

---

## What Happens

1. Downloads Spank.app (~3MB)
2. Installs to /Applications
3. Sets up the background service (requires password)
4. Launches the app

You'll see a **🍑** in your menu bar when it's running.

---

## Test It!

Give your MacBook a **hard slap** on the palm rest area. You should hear the sound!

---

## Using the App

Click the **🍑** peach in your menu bar to:
- **Start/Stop** slap detection
- **Adjust threshold** (higher = needs harder slap)
- **Adjust cooldown** (time between sounds)
- **Change sounds**
- **Test the sound**

---

## Troubleshooting

### Nothing happens when I slap?

1. Make sure you're slapping **hard** (threshold is set high to avoid false triggers)
2. Check the 🍑 menu - is it showing "Running"?
3. Try lowering the threshold slider

### "Apple cannot verify" error

Run in Terminal:
```bash
xattr -cr /Applications/Spank.app
```

### Uninstall

```bash
sudo launchctl unload /Library/LaunchDaemons/com.aj.spank.plist
sudo rm /Library/LaunchDaemons/com.aj.spank.plist
sudo rm /usr/local/bin/spank
rm -rf /Applications/Spank.app
rm -rf /Users/Shared/spank-sounds
```

---

## How It Works

Spank uses your MacBook's built-in accelerometer to detect physical impacts. When you slap it hard enough (above the threshold), it plays a sound.

The detection runs as a background service, so it works even when the app isn't open.

---

Made with 🍑 by AJ
