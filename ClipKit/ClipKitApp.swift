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

    init() {
        // Create shared settings manager, then clipboard manager with settings
        let settings = SettingsManager()
        let clipboard = ClipboardManager(settings: settings)
        _settingsManager = StateObject(wrappedValue: settings)
        _clipboardManager = StateObject(wrappedValue: clipboard)

        // Set reference immediately for quit handling
        AppDelegate.shared = clipboard
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(clipboardManager)
                .environmentObject(settingsManager)
        }
        .commands {
            CommandGroup(after: .textEditing) {
                Button("Focus Search") {
                    NotificationCenter.default.post(name: .focusSearch, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)
            }
        }

        Settings {
            SettingsView()
                .environmentObject(settingsManager)
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

// MARK: - Notification Names
extension Notification.Name {
    static let focusSearch = Notification.Name("focusSearch")
}
