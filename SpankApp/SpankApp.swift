import SwiftUI
import AppKit
import AVFoundation

// MARK: - Sound Model
struct SoundOption: Identifiable, Codable {
    let id: String          // filename without extension
    var name: String        // display name
    var emoji: String       // icon
    
    static func loadFromBundle() -> [SoundOption] {
        guard let soundsURL = Bundle.main.resourceURL?.appendingPathComponent("sounds") else {
            return []
        }
        
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(at: soundsURL, includingPropertiesForKeys: nil) else {
            return []
        }
        
        // Load custom names from manifest if exists, otherwise use filename
        let manifestURL = soundsURL.appendingPathComponent("manifest.json")
        var manifest: [String: SoundOption] = [:]
        
        if let data = try? Data(contentsOf: manifestURL),
           let decoded = try? JSONDecoder().decode([SoundOption].self, from: data) {
            manifest = Dictionary(uniqueKeysWithValues: decoded.map { ($0.id, $0) })
        }
        
        return files
            .filter { $0.pathExtension == "mp3" || $0.pathExtension == "wav" || $0.pathExtension == "m4a" }
            .map { url in
                let id = url.deletingPathExtension().lastPathComponent
                if let existing = manifest[id] {
                    return existing
                }
                // Default: use filename as name, speaker emoji
                let displayName = id.replacingOccurrences(of: "-", with: " ").capitalized
                return SoundOption(id: id, name: displayName, emoji: "🔊")
            }
            .sorted { $0.name < $1.name }
    }
}

// MARK: - App Entry Point
@main
struct SpankAppMain: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings { EmptyView() }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var audioPlayer: AVAudioPlayer?
    
    // State
    var isRunning = false
    var selectedSoundId: String {
        get { UserDefaults.standard.string(forKey: "selectedSound") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "selectedSound") }
    }
    var threshold: Double {
        get { UserDefaults.standard.double(forKey: "threshold").rounded() == 0 ? 0.8 : UserDefaults.standard.double(forKey: "threshold") }
        set { UserDefaults.standard.set(newValue, forKey: "threshold") }
    }
    var cooldown: Int {
        get { UserDefaults.standard.integer(forKey: "cooldown") == 0 ? 2000 : UserDefaults.standard.integer(forKey: "cooldown") }
        set { UserDefaults.standard.set(newValue, forKey: "cooldown") }
    }
    
    var sounds: [SoundOption] = []
    var statusTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        // Load sounds
        sounds = SoundOption.loadFromBundle()
        
        // Set default selection if none
        if selectedSoundId.isEmpty, let first = sounds.first {
            selectedSoundId = first.id
            applySoundSelection()
        }
        
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "🍑"
        }
        
        // Build menu
        rebuildMenu()
        
        // Check status periodically
        checkStatus()
        statusTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.checkStatus()
            self?.rebuildMenu()
        }
    }
    
    // MARK: - Menu Building
    func rebuildMenu() {
        let menu = NSMenu()
        
        // Header with status
        let statusItem = NSMenuItem(title: isRunning ? "● Running" : "○ Stopped", action: nil, keyEquivalent: "")
        statusItem.attributedTitle = NSAttributedString(
            string: isRunning ? "●  Running" : "○  Stopped",
            attributes: [
                .foregroundColor: isRunning ? NSColor.systemGreen : NSColor.secondaryLabelColor,
                .font: NSFont.systemFont(ofSize: 13, weight: .medium)
            ]
        )
        menu.addItem(statusItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Sounds submenu
        let soundsItem = NSMenuItem(title: "Sounds", action: nil, keyEquivalent: "")
        soundsItem.image = NSImage(systemSymbolName: "speaker.wave.2.fill", accessibilityDescription: nil)
        let soundsSubmenu = NSMenu()
        
        for sound in sounds {
            let item = NSMenuItem(
                title: "\(sound.emoji)  \(sound.name)",
                action: #selector(selectSound(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = sound.id
            item.state = sound.id == selectedSoundId ? .on : .off
            soundsSubmenu.addItem(item)
        }
        
        if sounds.isEmpty {
            let noSounds = NSMenuItem(title: "No sounds found", action: nil, keyEquivalent: "")
            noSounds.isEnabled = false
            soundsSubmenu.addItem(noSounds)
        }
        
        soundsItem.submenu = soundsSubmenu
        menu.addItem(soundsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Threshold submenu
        let thresholdItem = NSMenuItem(title: "Threshold", action: nil, keyEquivalent: "")
        thresholdItem.image = NSImage(systemSymbolName: "dial.low.fill", accessibilityDescription: nil)
        let thresholdSubmenu = NSMenu()
        
        let thresholdValues = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2]
        for value in thresholdValues {
            let label = String(format: "%.1fg", value) + (value == 0.8 ? "  (default)" : "")
            let item = NSMenuItem(title: label, action: #selector(selectThreshold(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = value
            item.state = abs(threshold - value) < 0.05 ? .on : .off
            thresholdSubmenu.addItem(item)
        }
        thresholdItem.submenu = thresholdSubmenu
        menu.addItem(thresholdItem)
        
        // Cooldown submenu
        let cooldownItem = NSMenuItem(title: "Cooldown", action: nil, keyEquivalent: "")
        cooldownItem.image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
        let cooldownSubmenu = NSMenu()
        
        let cooldownValues = [500, 1000, 1500, 2000, 2500, 3000, 4000, 5000]
        for value in cooldownValues {
            let label = "\(value)ms" + (value == 2000 ? "  (default)" : "")
            let item = NSMenuItem(title: label, action: #selector(selectCooldown(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = value
            item.state = cooldown == value ? .on : .off
            cooldownSubmenu.addItem(item)
        }
        cooldownItem.submenu = cooldownSubmenu
        menu.addItem(cooldownItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Test sound
        let testItem = NSMenuItem(title: "Test Sound", action: #selector(testSound), keyEquivalent: "t")
        testItem.target = self
        testItem.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
        menu.addItem(testItem)
        
        // Start/Stop
        let toggleItem = NSMenuItem(
            title: isRunning ? "Stop Detection" : "Start Detection",
            action: #selector(toggleSpank),
            keyEquivalent: isRunning ? "s" : "r"
        )
        toggleItem.target = self
        toggleItem.image = NSImage(systemSymbolName: isRunning ? "stop.fill" : "play.circle.fill", accessibilityDescription: nil)
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit Spank", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Footer
        let footerItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        footerItem.attributedTitle = NSAttributedString(
            string: "Built by AJ — spank your laptop!",
            attributes: [
                .foregroundColor: NSColor.tertiaryLabelColor,
                .font: NSFont.systemFont(ofSize: 11, weight: .regular)
            ]
        )
        menu.addItem(footerItem)
        
        self.statusItem.menu = menu
    }
    
    // MARK: - Actions
    @objc func selectSound(_ sender: NSMenuItem) {
        guard let soundId = sender.representedObject as? String else { return }
        selectedSoundId = soundId
        applySoundSelection()
        rebuildMenu()
    }
    
    @objc func selectThreshold(_ sender: NSMenuItem) {
        guard let value = sender.representedObject as? Double else { return }
        threshold = value
        if isRunning { restartDaemon() }
        rebuildMenu()
    }
    
    @objc func selectCooldown(_ sender: NSMenuItem) {
        guard let value = sender.representedObject as? Int else { return }
        cooldown = value
        if isRunning { restartDaemon() }
        rebuildMenu()
    }
    
    @objc func testSound() {
        guard let soundsURL = Bundle.main.resourceURL?.appendingPathComponent("sounds") else { return }
        
        // Find selected sound file
        let extensions = ["mp3", "wav", "m4a"]
        for ext in extensions {
            let url = soundsURL.appendingPathComponent("\(selectedSoundId).\(ext)")
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.play()
                } catch {
                    print("Error playing sound: \(error)")
                }
                return
            }
        }
    }
    
    @objc func toggleSpank() {
        // Instead of stopping daemon (requires sudo), we enable/disable by managing sounds folder
        let destDir = "/Users/Shared/spank-sounds"
        let disabledMarker = "\(destDir)/.disabled"
        
        if isRunning {
            // "Stop" = remove sounds and add marker
            if let files = try? FileManager.default.contentsOfDirectory(atPath: destDir) {
                for file in files where !file.hasPrefix(".") {
                    try? FileManager.default.removeItem(atPath: "\(destDir)/\(file)")
                }
            }
            FileManager.default.createFile(atPath: disabledMarker, contents: nil)
        } else {
            // "Start" = remove marker and restore sound
            try? FileManager.default.removeItem(atPath: disabledMarker)
            applySoundSelection()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.checkStatus()
            self?.rebuildMenu()
        }
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Helpers
    func checkStatus() {
        // Check if disabled marker exists (means user "stopped" it)
        let disabledMarker = "/Users/Shared/spank-sounds/.disabled"
        let isDisabled = FileManager.default.fileExists(atPath: disabledMarker)
        
        // Check if daemon is running
        let task = Process()
        task.launchPath = "/usr/bin/pgrep"
        task.arguments = ["-f", "spank --custom"]
        task.standardOutput = FileHandle.nullDevice
        task.standardError = FileHandle.nullDevice
        try? task.run()
        task.waitUntilExit()
        let daemonRunning = task.terminationStatus == 0
        
        // Running = daemon is running AND not disabled
        isRunning = daemonRunning && !isDisabled
    }
    
    func applySoundSelection() {
        guard let soundsURL = Bundle.main.resourceURL?.appendingPathComponent("sounds") else { return }
        
        let destDir = "/Users/Shared/spank-sounds"
        let destFile = "\(destDir)/sound.mp3"
        
        // Find the sound file
        let extensions = ["mp3", "wav", "m4a"]
        for ext in extensions {
            let sourceURL = soundsURL.appendingPathComponent("\(selectedSoundId).\(ext)")
            if FileManager.default.fileExists(atPath: sourceURL.path) {
                // Copy to shared location (need admin for first time, but folder should be writable)
                do {
                    // Remove old files
                    if let files = try? FileManager.default.contentsOfDirectory(atPath: destDir) {
                        for file in files {
                            try? FileManager.default.removeItem(atPath: "\(destDir)/\(file)")
                        }
                    }
                    // Copy new sound
                    try FileManager.default.copyItem(atPath: sourceURL.path, toPath: destFile)
                } catch {
                    // Try with admin privileges
                    let script = """
                    do shell script "rm -f \(destDir)/* 2>/dev/null; cp '\(sourceURL.path)' '\(destFile)'" with administrator privileges
                    """
                    var err: NSDictionary?
                    NSAppleScript(source: script)?.executeAndReturnError(&err)
                }
                return
            }
        }
    }
    
    func restartDaemon() {
        let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key><string>com.aj.spank</string>
            <key>ProgramArguments</key>
            <array>
                <string>/usr/local/bin/spank</string>
                <string>--custom</string>
                <string>/Users/Shared/spank-sounds</string>
                <string>--min-amplitude</string>
                <string>\(String(format: "%.1f", threshold))</string>
                <string>--cooldown</string>
                <string>\(cooldown)</string>
            </array>
            <key>RunAtLoad</key><true/>
            <key>KeepAlive</key><true/>
        </dict>
        </plist>
        """
        
        let tempPath = "/tmp/spank-update.plist"
        try? plist.write(toFile: tempPath, atomically: true, encoding: .utf8)
        
        let script = """
        do shell script "launchctl unload /Library/LaunchDaemons/com.aj.spank.plist 2>/dev/null; cp \(tempPath) /Library/LaunchDaemons/com.aj.spank.plist; launchctl load /Library/LaunchDaemons/com.aj.spank.plist" with administrator privileges
        """
        
        var error: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&error)
    }
}
