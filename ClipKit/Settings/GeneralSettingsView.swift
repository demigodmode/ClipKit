//
//  GeneralSettingsView.swift
//  ClipKit
//
//  General settings tab: launch at login, clear on quit.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("clearHistoryOnQuit") private var clearHistoryOnQuit = false

    var body: some View {
        Form {
            Section {
                Toggle("Launch ClipKit at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        LaunchAtLoginHelper.setEnabled(newValue)
                    }
                    .onAppear {
                        // Sync UI state with actual system state
                        launchAtLogin = LaunchAtLoginHelper.isEnabled
                    }
            } header: {
                Text("Startup")
            }

            Section {
                Toggle("Clear clipboard history when quitting", isOn: $clearHistoryOnQuit)
            } header: {
                Text("Privacy")
            } footer: {
                Text("When enabled, ephemeral clipboard items will be cleared when you quit ClipKit. Pinned items are always preserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
