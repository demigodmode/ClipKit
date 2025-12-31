//
//  LimitsSettingsView.swift
//  ClipKit
//
//  Limits settings tab: max pinned items, max ephemeral items, polling interval.
//

import SwiftUI

struct LimitsSettingsView: View {
    @AppStorage("maxPinnedCount") private var maxPinnedCount = 12
    @AppStorage("maxEphemeralCount") private var maxEphemeralCount = 100
    @AppStorage("pollingInterval") private var pollingInterval = 0.5

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Maximum pinned items")
                    Spacer()
                    Stepper("\(maxPinnedCount)", value: $maxPinnedCount, in: 1...50)
                        .frame(width: 100)
                }

                HStack {
                    Text("Maximum history items")
                    Spacer()
                    Stepper("\(maxEphemeralCount)", value: $maxEphemeralCount, in: 10...500, step: 10)
                        .frame(width: 100)
                }
            } header: {
                Text("Storage Limits")
            } footer: {
                Text("Older items will be automatically removed when limits are exceeded.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                HStack {
                    Text("Clipboard check interval")
                    Spacer()
                    Picker("", selection: $pollingInterval) {
                        Text("0.1s (Fast)").tag(0.1)
                        Text("0.25s").tag(0.25)
                        Text("0.5s (Default)").tag(0.5)
                        Text("1.0s").tag(1.0)
                        Text("2.0s (Slow)").tag(2.0)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)
                }
            } header: {
                Text("Performance")
            } footer: {
                Text("Faster intervals detect clipboard changes more quickly but use more resources.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
