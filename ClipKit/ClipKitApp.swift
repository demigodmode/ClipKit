//
//  ClipKitApp.swift
//  ClipKit
//
//  Created by Adheesh Saxena on 12/24/24.
//

import SwiftUI

@main
struct ClipKitApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settingsManager: SettingsManager
    @StateObject private var clipboardManager: ClipboardManager
    @StateObject private var shortcutManager: GlobalShortcutManager

    init() {
        // Create shared settings manager, then other managers
        let settings = SettingsManager()
        let clipboard = ClipboardManager(settings: settings)
        let shortcuts = GlobalShortcutManager(settings: settings)

        _settingsManager = StateObject(wrappedValue: settings)
        _clipboardManager = StateObject(wrappedValue: clipboard)
        _shortcutManager = StateObject(wrappedValue: shortcuts)

        // Set reference immediately for quit handling
        AppDelegate.shared = clipboard
    }

    @State private var showingHelp = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(clipboardManager)
                .environmentObject(settingsManager)
                .environmentObject(shortcutManager)
                .sheet(isPresented: $showingHelp) {
                    HelpView()
                }
        }
        .commands {
            CommandGroup(replacing: .help) {
                Button("ClipKit Help") {
                    showingHelp = true
                }
            }
        }

        Settings {
            SettingsView()
                .environmentObject(settingsManager)
                .environmentObject(shortcutManager)
        }
    }
}

// MARK: - App Delegate for handling app lifecycle events
class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: ClipboardManager?

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        AppDelegate.shared?.clearHistoryIfNeeded()
        return .terminateNow
    }
}

