import SwiftUI
import AppKit

@main
struct SpankAppMain: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings { EmptyView() }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "🍑"
            button.action = #selector(togglePopover)
        }
        
        popover = NSPopover()
        popover.contentSize = NSSize(width: 260, height: 280)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: SpankMenuView())
    }
    
    @objc func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

struct SpankMenuView: View {
    @State private var isRunning = false
    @State private var threshold: Double = 0.8
    @State private var cooldown: Double = 2000
    @State private var soundsPath = "/Users/Shared/spank-sounds"
    @State private var needsInstall = false
    
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("🍑")
                    .font(.title2)
                Text("Spank")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(isRunning ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                Text(isRunning ? "Running" : "Stopped")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            if needsInstall {
                installSection
            } else {
                controlsSection
            }
            
            Divider()
            
            Button("Quit App") { NSApp.terminate(nil) }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 260)
        .onAppear { checkStatus() }
        .onReceive(timer) { _ in checkStatus() }
    }
    
    private var installSection: some View {
        VStack(spacing: 10) {
            Text("Setup Required")
                .font(.subheadline)
                .fontWeight(.medium)
            Text("Run the installer once to enable spank detection.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Open Installer") { openInstaller() }
                .buttonStyle(.borderedProminent)
        }
    }
    
    private var controlsSection: some View {
        VStack(spacing: 12) {
            // Start/Stop
            Button(action: toggleSpank) {
                HStack {
                    Image(systemName: isRunning ? "stop.fill" : "play.fill")
                    Text(isRunning ? "Stop" : "Start")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(isRunning ? .red : .green)
            
            // Test Sound
            Button(action: testSound) {
                HStack {
                    Image(systemName: "speaker.wave.2")
                    Text("Test Sound")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Divider()
            
            // Threshold
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Threshold")
                    Spacer()
                    Text(String(format: "%.1fg", threshold))
                        .foregroundColor(.secondary)
                }
                .font(.caption)
                Slider(value: $threshold, in: 0.3...1.2, step: 0.1)
                    .onChange(of: threshold) { _ in updateDaemon() }
            }
            
            // Cooldown
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Cooldown")
                    Spacer()
                    Text(String(format: "%.0fms", cooldown))
                        .foregroundColor(.secondary)
                }
                .font(.caption)
                Slider(value: $cooldown, in: 500...5000, step: 250)
                    .onChange(of: cooldown) { _ in updateDaemon() }
            }
            
            // Sounds folder
            HStack {
                Text(soundsPath.replacingOccurrences(of: "/Users/Shared/", with: "~/Shared/"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Spacer()
                Button("Change") { selectFolder() }
                    .controlSize(.small)
            }
        }
    }
    
    func checkStatus() {
        let task = Process()
        task.launchPath = "/usr/bin/pgrep"
        task.arguments = ["-f", "spank --custom"]
        task.standardOutput = FileHandle.nullDevice
        try? task.run()
        task.waitUntilExit()
        isRunning = task.terminationStatus == 0
        
        // Check if daemon is installed
        needsInstall = !FileManager.default.fileExists(atPath: "/Library/LaunchDaemons/com.aj.spank.plist")
    }
    
    func toggleSpank() {
        let script = isRunning
            ? "do shell script \"launchctl unload /Library/LaunchDaemons/com.aj.spank.plist\" with administrator privileges"
            : "do shell script \"launchctl load /Library/LaunchDaemons/com.aj.spank.plist\" with administrator privileges"
        
        var error: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { checkStatus() }
    }
    
    func updateDaemon() {
        guard isRunning else { return }
        // Restart with new settings
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
                <string>\(soundsPath)</string>
                <string>--min-amplitude</string>
                <string>\(String(format: "%.1f", threshold))</string>
                <string>--cooldown</string>
                <string>\(Int(cooldown))</string>
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
    
    func testSound() {
        let files = (try? FileManager.default.contentsOfDirectory(atPath: soundsPath)) ?? []
        if let mp3 = files.first(where: { $0.hasSuffix(".mp3") }) {
            NSSound(contentsOfFile: soundsPath + "/" + mp3, byReference: true)?.play()
        }
    }
    
    func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK, let url = panel.url {
            soundsPath = url.path
            if isRunning { updateDaemon() }
        }
    }
    
    func openInstaller() {
        let script = """
        tell application "Terminal"
            activate
            do script "cd ~/Developer/SpankApp && sudo ./install-simple.sh"
        end tell
        """
        var error: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&error)
    }
}
