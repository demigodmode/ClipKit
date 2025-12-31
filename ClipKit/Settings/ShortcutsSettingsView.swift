//
//  ShortcutsSettingsView.swift
//  ClipKit
//
//  Settings tab for configuring global shortcuts.
//

import SwiftUI
import Carbon.HIToolbox

struct ShortcutsSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var shortcutManager: GlobalShortcutManager

    @State private var isRecording = false
    @State private var accessibilityGranted = AccessibilityHelper.isAccessibilityEnabled

    var body: some View {
        Form {
            // Accessibility Permission Section
            Section {
                HStack {
                    if accessibilityGranted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Accessibility permission granted")
                    } else {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Accessibility permission required")
                    }
                    Spacer()
                    if !accessibilityGranted {
                        Button("Open Settings") {
                            AccessibilityHelper.openAccessibilitySettings()
                        }
                        Button("Refresh") {
                            accessibilityGranted = AccessibilityHelper.isAccessibilityEnabled
                            if accessibilityGranted {
                                shortcutManager.registerShortcut()
                            }
                        }
                    }
                }
            } header: {
                Text("Permissions")
            } footer: {
                if !accessibilityGranted {
                    Text("Global shortcuts require Accessibility permission. Click 'Open Settings' and enable ClipKit in Privacy & Security → Accessibility. Then click 'Refresh'.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Global Shortcut Section
            Section {
                HStack {
                    Text("Show/Hide ClipKit")
                    Spacer()

                    if isRecording {
                        Text("Press shortcut...")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(0.2))
                            .cornerRadius(6)
                    } else {
                        Button(action: { isRecording = true }) {
                            Text(currentShortcutString)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(
                    ShortcutRecorderView(
                        isRecording: $isRecording,
                        onShortcutRecorded: { keyCode, modifiers in
                            settingsManager.globalShortcutKeyCode = keyCode
                            settingsManager.globalShortcutModifiers = modifiers
                            shortcutManager.registerShortcut()
                        }
                    )
                )

                HStack {
                    Text("Status")
                    Spacer()
                    if shortcutManager.isEnabled {
                        Label("Active", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Label("Inactive", systemImage: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Global Shortcut")
            } footer: {
                Text("Click the shortcut button and press a new key combination. Must include at least one modifier (⌘, ⇧, ⌥, or ⌃) with a letter or number.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // In-App Shortcuts Reference
            Section {
                shortcutRow("↑ / ↓", "Navigate items")
                shortcutRow("Return", "Copy selected item")
                shortcutRow("Delete", "Remove selected item")
                shortcutRow("P", "Pin/unpin selected item")
                shortcutRow("Escape", "Clear selection")
            } header: {
                Text("In-App Shortcuts (Reference)")
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            accessibilityGranted = AccessibilityHelper.isAccessibilityEnabled
        }
    }

    private var currentShortcutString: String {
        GlobalShortcutManager.shortcutDisplayString(
            keyCode: settingsManager.globalShortcutKeyCode,
            modifiers: settingsManager.globalShortcutModifiers
        )
    }

    private func shortcutRow(_ shortcut: String, _ description: String) -> some View {
        HStack {
            Text(shortcut)
                .font(.system(.body, design: .monospaced))
                .frame(width: 70, alignment: .leading)
            Text(description)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

// MARK: - Shortcut Recorder
struct ShortcutRecorderView: NSViewRepresentable {
    @Binding var isRecording: Bool
    let onShortcutRecorded: (Int, Int) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = ShortcutCaptureView()
        view.onShortcutRecorded = { keyCode, modifiers in
            onShortcutRecorded(keyCode, modifiers)
            isRecording = false
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let view = nsView as? ShortcutCaptureView {
            view.isRecording = isRecording
        }
    }
}

class ShortcutCaptureView: NSView {
    var isRecording = false
    var onShortcutRecorded: ((Int, Int) -> Void)?

    private var localMonitor: Any?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        setupMonitor()
    }

    private func setupMonitor() {
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, self.isRecording else { return event }

            // Require at least one modifier (Cmd, Shift, Option, or Control)
            let modifiers = event.modifierFlags.intersection([.command, .shift, .option, .control])
            guard !modifiers.isEmpty else { return event }

            // Don't allow modifier-only presses
            let keyCode = Int(event.keyCode)
            if keyCode == kVK_Command || keyCode == kVK_Shift ||
               keyCode == kVK_Option || keyCode == kVK_Control ||
               keyCode == kVK_RightCommand || keyCode == kVK_RightShift ||
               keyCode == kVK_RightOption || keyCode == kVK_RightControl {
                return event
            }

            self.onShortcutRecorded?(keyCode, Int(modifiers.rawValue))
            return nil
        }
    }

    deinit {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
