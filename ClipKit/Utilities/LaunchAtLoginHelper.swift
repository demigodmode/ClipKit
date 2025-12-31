//
//  LaunchAtLoginHelper.swift
//  ClipKit
//
//  Helper for managing launch at login using SMAppService (macOS 13+).
//

import Foundation
import ServiceManagement

enum LaunchAtLoginHelper {
    /// Enable or disable launch at login
    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
        }
    }

    /// Check if launch at login is currently enabled
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }
}
