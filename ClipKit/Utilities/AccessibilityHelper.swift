//
//  AccessibilityHelper.swift
//  ClipKit
//
//  Helper for checking and requesting Accessibility permissions.
//  Required for global keyboard shortcuts.
//

import Cocoa
import ApplicationServices

enum AccessibilityHelper {
    /// Check if the app has Accessibility permission
    static var isAccessibilityEnabled: Bool {
        AXIsProcessTrusted()
    }

    /// Check permission and optionally prompt user to grant it
    static func checkAccessibility(prompt: Bool = false) -> Bool {
        if prompt {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            return AXIsProcessTrustedWithOptions(options)
        } else {
            return AXIsProcessTrusted()
        }
    }

    /// Open System Settings to the Accessibility pane
    static func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
