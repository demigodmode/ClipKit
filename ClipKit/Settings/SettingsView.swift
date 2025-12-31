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

            ShortcutsSettingsView()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
        }
        .frame(width: 500, height: 400)
    }
}
