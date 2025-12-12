//
//  ClipKitApp.swift
//  ClipKit
//
//  Created by Adheesh Saxena on 12/24/24.
//

import SwiftUI

@main
struct ClipKitApp: App {
    @StateObject private var clipboardManager = ClipboardManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(clipboardManager)
        }
    }
}
