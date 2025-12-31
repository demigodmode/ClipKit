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
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var clipboardManager: ClipboardManager

    init() {
        // Create settings manager first, then clipboard manager with settings
        let settings = SettingsManager()
        _settingsManager = StateObject(wrappedValue: settings)
        _clipboardManager = StateObject(wrappedValue: ClipboardManager(settings: settings))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(clipboardManager)
                .environmentObject(settingsManager)
                .onAppear {
                    // Share references with AppDelegate for quit handling
                    appDelegate.clipboardManager = clipboardManager
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
    var clipboardManager: ClipboardManager?

    func applicationWillTerminate(_ notification: Notification) {
        clipboardManager?.clearHistoryIfNeeded()
    }
}
