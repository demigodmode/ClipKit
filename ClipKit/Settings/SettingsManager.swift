//
//  SettingsManager.swift
//  ClipKit
//
//  Central manager for all user preferences using @AppStorage.
//

import SwiftUI
import Combine

final class SettingsManager: ObservableObject {
    // MARK: - Limits
    @AppStorage("maxPinnedCount") var maxPinnedCount: Int = 12
    @AppStorage("maxEphemeralCount") var maxEphemeralCount: Int = 100
    @AppStorage("pollingInterval") var pollingInterval: Double = 0.5

    // MARK: - General
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("clearHistoryOnQuit") var clearHistoryOnQuit: Bool = false

    // MARK: - UI Preferences (persisted across launches)
    @AppStorage("sortMode") var sortMode: String = "recent"
    @AppStorage("dataTypeFilter") var dataTypeFilter: String = "all"
    @AppStorage("groupEphemeralByType") var groupEphemeralByType: Bool = false

    // MARK: - Global Shortcut (stored as JSON)
    @AppStorage("globalShortcutKeyCode") var globalShortcutKeyCode: Int = 9  // V key
    @AppStorage("globalShortcutModifiers") var globalShortcutModifiers: Int = 768  // Cmd+Shift

    // MARK: - Publisher for settings changes
    private var cancellables = Set<AnyCancellable>()

    /// Publisher that emits when polling interval changes
    let pollingIntervalDidChange = PassthroughSubject<Double, Never>()

    init() {
        // Observe polling interval changes to notify ClipboardManager
        objectWillChange
            .sink { [weak self] _ in
                // Delay slightly to ensure the value is updated
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let self = self {
                        self.pollingIntervalDidChange.send(self.pollingInterval)
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties for Enums
    var sortModeEnum: SortMode {
        get { SortMode(rawValue: sortMode) ?? .recent }
        set { sortMode = newValue.rawValue }
    }

    var dataTypeFilterEnum: DataTypeFilter {
        get { DataTypeFilter(rawValue: dataTypeFilter) ?? .all }
        set { dataTypeFilter = newValue.rawValue }
    }
}

// MARK: - Sort Mode Enum
enum SortMode: String, CaseIterable {
    case recent = "recent"
    case alphabetical = "alphabetical"

    var displayName: String {
        switch self {
        case .recent: return "Most Recent"
        case .alphabetical: return "Alphabetical"
        }
    }
}

// MARK: - Data Type Filter Enum
enum DataTypeFilter: String, CaseIterable {
    case all = "all"
    case textOnly = "textOnly"
    case imagesOnly = "imagesOnly"

    var displayName: String {
        switch self {
        case .all: return "All Types"
        case .textOnly: return "Text Only"
        case .imagesOnly: return "Images Only"
        }
    }
}
