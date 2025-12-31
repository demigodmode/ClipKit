//
//  SettingsView.swift
//  ClipKit
//
//  Main Settings window with tabbed interface.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            LimitsSettingsView()
                .tabItem {
                    Label("Limits", systemImage: "slider.horizontal.3")
                }

            // Shortcuts tab will be added in Phase 3
        }
        .frame(width: 450, height: 300)
    }
}
