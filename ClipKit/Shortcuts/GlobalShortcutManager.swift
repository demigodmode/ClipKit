//
//  GlobalShortcutManager.swift
//  ClipKit
//
//  Manages global keyboard shortcuts using HotKey.
//

import SwiftUI
import HotKey
import Carbon.HIToolbox

final class GlobalShortcutManager: ObservableObject {
    @Published var isEnabled: Bool = false

    private var hotKey: HotKey?
    private let settingsManager: SettingsManager

    init(settings: SettingsManager) {
        self.settingsManager = settings
        registerShortcut()
    }

    /// Register the global shortcut based on current settings
    func registerShortcut() {
        // Unregister existing shortcut
        hotKey = nil

        // Check if we have accessibility permission
        guard AccessibilityHelper.isAccessibilityEnabled else {
            isEnabled = false
            return
        }

        // Get key and modifiers from settings
        let keyCode = settingsManager.globalShortcutKeyCode
        let modifierFlags = settingsManager.globalShortcutModifiers

        // Convert to HotKey types
        guard let key = keyFromKeyCode(UInt32(keyCode)) else {
            isEnabled = false
            return
        }

        let modifiers = modifiersFromFlags(modifierFlags)

        // Create and register the hotkey
        hotKey = HotKey(key: key, modifiers: modifiers)
        hotKey?.keyDownHandler = { [weak self] in
            self?.toggleMainWindow()
        }

        isEnabled = true
    }

    /// Unregister the global shortcut
    func unregisterShortcut() {
        hotKey = nil
        isEnabled = false
    }

    /// Toggle the main window visibility
    private func toggleMainWindow() {
        DispatchQueue.main.async {
            if let window = NSApp.windows.first(where: { $0.title == "ClipKit" || $0.isMainWindow }) {
                if window.isKeyWindow && window.isVisible {
                    window.orderOut(nil)
                } else {
                    window.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                }
            } else {
                // If no window found, just activate the app
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    /// Convert key code to HotKey Key
    private func keyFromKeyCode(_ keyCode: UInt32) -> Key? {
        // Map common key codes to HotKey Key enum
        switch Int(keyCode) {
        case kVK_ANSI_A: return .a
        case kVK_ANSI_B: return .b
        case kVK_ANSI_C: return .c
        case kVK_ANSI_D: return .d
        case kVK_ANSI_E: return .e
        case kVK_ANSI_F: return .f
        case kVK_ANSI_G: return .g
        case kVK_ANSI_H: return .h
        case kVK_ANSI_I: return .i
        case kVK_ANSI_J: return .j
        case kVK_ANSI_K: return .k
        case kVK_ANSI_L: return .l
        case kVK_ANSI_M: return .m
        case kVK_ANSI_N: return .n
        case kVK_ANSI_O: return .o
        case kVK_ANSI_P: return .p
        case kVK_ANSI_Q: return .q
        case kVK_ANSI_R: return .r
        case kVK_ANSI_S: return .s
        case kVK_ANSI_T: return .t
        case kVK_ANSI_U: return .u
        case kVK_ANSI_V: return .v
        case kVK_ANSI_W: return .w
        case kVK_ANSI_X: return .x
        case kVK_ANSI_Y: return .y
        case kVK_ANSI_Z: return .z
        case kVK_ANSI_0: return .zero
        case kVK_ANSI_1: return .one
        case kVK_ANSI_2: return .two
        case kVK_ANSI_3: return .three
        case kVK_ANSI_4: return .four
        case kVK_ANSI_5: return .five
        case kVK_ANSI_6: return .six
        case kVK_ANSI_7: return .seven
        case kVK_ANSI_8: return .eight
        case kVK_ANSI_9: return .nine
        case kVK_Space: return .space
        default: return nil
        }
    }

    /// Convert modifier flags int to NSEvent.ModifierFlags
    private func modifiersFromFlags(_ flags: Int) -> NSEvent.ModifierFlags {
        var modifiers: NSEvent.ModifierFlags = []
        let uflags = UInt(flags)
        if uflags & NSEvent.ModifierFlags.command.rawValue != 0 {
            modifiers.insert(.command)
        }
        if uflags & NSEvent.ModifierFlags.shift.rawValue != 0 {
            modifiers.insert(.shift)
        }
        if uflags & NSEvent.ModifierFlags.option.rawValue != 0 {
            modifiers.insert(.option)
        }
        if uflags & NSEvent.ModifierFlags.control.rawValue != 0 {
            modifiers.insert(.control)
        }
        return modifiers
    }
}

// MARK: - Shortcut Display Helper
extension GlobalShortcutManager {
    /// Get a human-readable string for the current shortcut
    static func shortcutDisplayString(keyCode: Int, modifiers: Int) -> String {
        var parts: [String] = []
        let umodifiers = UInt(modifiers)

        if umodifiers & NSEvent.ModifierFlags.control.rawValue != 0 {
            parts.append("⌃")
        }
        if umodifiers & NSEvent.ModifierFlags.option.rawValue != 0 {
            parts.append("⌥")
        }
        if umodifiers & NSEvent.ModifierFlags.shift.rawValue != 0 {
            parts.append("⇧")
        }
        if umodifiers & NSEvent.ModifierFlags.command.rawValue != 0 {
            parts.append("⌘")
        }

        parts.append(keyDisplayString(keyCode))

        return parts.joined()
    }

    private static func keyDisplayString(_ keyCode: Int) -> String {
        switch keyCode {
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_Space: return "Space"
        default: return "?"
        }
    }
}
