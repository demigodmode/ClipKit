//
//  HelpView.swift
//  ClipKit
//
//  Help documentation for ClipKit.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Image(systemName: "doc.on.clipboard")
                        .font(.largeTitle)
                    Text("ClipKit Help")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 8)

                // Overview
                Section {
                    Text("ClipKit is a clipboard manager that keeps track of everything you copy. Items are organized into two sections:")

                    VStack(alignment: .leading, spacing: 8) {
                        Label("**Pinned** - Items you want to keep permanently (persists across reboots)", systemImage: "pin.fill")
                        Label("**Recent (Ephemeral)** - Recent clipboard history (clears on reboot)", systemImage: "clock")
                    }
                    .padding(.leading)
                } header: {
                    sectionHeader("Overview")
                }

                // Keyboard Shortcuts
                Section {
                    shortcutRow("↑ / ↓", "Navigate through items")
                    shortcutRow("Return", "Copy selected item to clipboard")
                    shortcutRow("Delete", "Remove selected item")
                    shortcutRow("P", "Pin or unpin selected item")
                    shortcutRow("Escape", "Clear selection")
                    shortcutRow("⌘ ,", "Open Settings")
                } header: {
                    sectionHeader("Keyboard Shortcuts")
                }

                // Settings
                Section {
                    Text("Access settings via **ClipKit → Settings** or press **⌘,**")

                    VStack(alignment: .leading, spacing: 8) {
                        Label("**Max Pinned Items** - How many items you can pin (default: 12)", systemImage: "pin")
                        Label("**Max History Items** - How many recent items to keep (default: 100)", systemImage: "list.bullet")
                        Label("**Polling Interval** - How often to check for clipboard changes", systemImage: "timer")
                        Label("**Launch at Login** - Start ClipKit when you log in", systemImage: "power")
                        Label("**Clear History on Quit** - Erase ephemeral items when quitting", systemImage: "trash")
                    }
                    .padding(.leading)
                } header: {
                    sectionHeader("Settings")
                }

                // Tips
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Click any item to copy it back to your clipboard", systemImage: "hand.tap")
                        Label("Drag pinned items to reorder them (in 'Most Recent' sort mode)", systemImage: "arrow.up.arrow.down")
                        Label("Use the search field to filter items", systemImage: "magnifyingglass")
                        Label("Yellow highlight shows the most recently copied item", systemImage: "star.fill")
                        Label("Blue highlight shows the currently selected item (keyboard)", systemImage: "square.dashed")
                    }
                    .padding(.leading)
                } header: {
                    sectionHeader("Tips")
                }

                Spacer()
            }
            .padding(24)
        }
        .frame(width: 500, height: 600)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.secondary)
    }

    private func shortcutRow(_ shortcut: String, _ description: String) -> some View {
        HStack {
            Text(shortcut)
                .font(.system(.body, design: .monospaced))
                .frame(width: 80, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(4)
            Text(description)
            Spacer()
        }
    }
}
