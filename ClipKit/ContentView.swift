//
//  ContentView.swift
//  ClipKit
//
//  Created by Adheesh Saxena on 12/24/24.
//

import SwiftUI

// MARK: - Sort & Filter Enums

enum SortMode: String, CaseIterable {
    case recent = "Most Recent"
    case alphabetical = "Alphabetical"
}

enum DataTypeFilter: String, CaseIterable {
    case all = "All Types"
    case textOnly = "Text Only"
    case imagesOnly = "Images Only"
}

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager

    // Local states for user preferences
    @State private var searchQuery = ""
    @State private var sortMode: SortMode = .recent
    @State private var dataTypeFilter: DataTypeFilter = .all
    @State private var groupEphemeralByType = false

    var body: some View {
        // The main pinned + ephemeral UI
        content
            .toolbar {
                // Put *all* items in one group. We add a Spacer() before the search field
                // so the search bar appears on the far right side of the toolbar.
                ToolbarItemGroup(placement: .automatic) {
                    // Sort mode
                    Picker("Sort By", selection: $sortMode) {
                        ForEach(SortMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    // Data type filter
                    Picker("Data Type", selection: $dataTypeFilter) {
                        ForEach(DataTypeFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    // Toggle grouping ephemeral by type
                    Toggle("Group By Type", isOn: $groupEphemeralByType)

                    // Spacer to push the search bar to the right
                    Spacer()

                    // The search bar
                    TextField("Search clipboard...", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 150)
                }
            }
    }

    /// The pinned & ephemeral UI
    private var content: some View {
        VStack(alignment: .leading) {
            // ----- Pinned Section -----
            Text("Pinned (Max \(clipboardManager.pinnedItems.count)/\(12))")
                .font(.headline)

            let filteredPinned = clipboardManager.pinnedItems
                .filter { $0.matchesSearch(searchQuery) }
                .filter { dataTypeFilterAllows($0, filter: dataTypeFilter) }
            let sortedPinned = sortClipboardItems(filteredPinned, by: sortMode)

            if sortedPinned.isEmpty {
                Text("No pinned items match your search/filter.")
                    .foregroundColor(.secondary)
            } else {
                List(sortedPinned, id: \.id) { item in
                    ClipboardItemRow(item: item, pinned: true)
                }
                .frame(minHeight: 100)
            }

            Divider().padding(.vertical, 8)

            // ----- Ephemeral Section -----
            Text("Recent (Ephemeral)")
                .font(.headline)

            let filteredEphemeral = clipboardManager.ephemeralItems
                .filter { $0.matchesSearch(searchQuery) }
                .filter { dataTypeFilterAllows($0, filter: dataTypeFilter) }
            let sortedEphemeral = sortClipboardItems(filteredEphemeral, by: sortMode)

            // Group ephemeral by data type if toggled
            if groupEphemeralByType {
                let textItems = sortedEphemeral.filter { if case .text = $0 { return true } else { return false } }
                let imageItems = sortedEphemeral.filter { if case .image = $0 { return true } else { return false } }

                if textItems.isEmpty && imageItems.isEmpty {
                    Text("No ephemeral items match your search/filter.")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        if !textItems.isEmpty {
                            Section(header: Text("Text Items")) {
                                ForEach(textItems, id: \.id) { item in
                                    ClipboardItemRow(item: item, pinned: false)
                                }
                            }
                        }
                        if !imageItems.isEmpty {
                            Section(header: Text("Images")) {
                                ForEach(imageItems, id: \.id) { item in
                                    ClipboardItemRow(item: item, pinned: false)
                                }
                            }
                        }
                    }
                    .frame(minHeight: 200)
                }
            } else {
                // Normal single list
                if sortedEphemeral.isEmpty {
                    Text("No ephemeral items match your search/filter.")
                        .foregroundColor(.secondary)
                } else {
                    List(sortedEphemeral, id: \.id) { item in
                        ClipboardItemRow(item: item, pinned: false)
                    }
                    .frame(minHeight: 200)
                }
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 600)
    }
}

// MARK: - ClipboardItemRow
struct ClipboardItemRow: View {
    let item: ClipboardContent
    let pinned: Bool

    @EnvironmentObject var manager: ClipboardManager

    @State private var showFlash = false

    var isTopEphemeral: Bool {
        guard let first = manager.ephemeralItems.first else { return false }
        return first == item
    }

    var body: some View {
        HStack {
            switch item {
            case .text(let text):
                Text(text)
                    .lineLimit(1)
                    .truncationMode(.tail)
            case .image(let data):
                if let nsImage = NSImage(data: data) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                } else {
                    Text("Corrupt image")
                        .foregroundColor(.red)
                }
            }

            Spacer()

            if pinned {
                Button(action: { manager.unpinItem(item) }) {
                    Image(systemName: "pin.slash.fill")
                }
                .buttonStyle(BorderlessButtonStyle())
            } else {
                Button(action: { manager.pinItem(item) }) {
                    Image(systemName: "pin")
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .contentShape(Rectangle())
        .background(
            ZStack {
                if isTopEphemeral {
                    Color.yellow.opacity(0.15)
                }
                if showFlash {
                    Color.blue.opacity(0.2)
                }
            }
        )
        .animation(.easeInOut(duration: 0.3), value: showFlash)
        .onTapGesture {
            showFlash = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showFlash = false
            }
            manager.restoreToPasteboard(item)
        }
    }
}

// MARK: - Sorting & Filtering Helpers
func sortClipboardItems(_ items: [ClipboardContent], by mode: SortMode) -> [ClipboardContent] {
    switch mode {
    case .recent:
        return items
    case .alphabetical:
        return items.sorted {
            $0.textRepresentation.localizedCaseInsensitiveCompare($1.textRepresentation) == .orderedAscending
        }
    }
}

func dataTypeFilterAllows(_ item: ClipboardContent, filter: DataTypeFilter) -> Bool {
    switch filter {
    case .all:
        return true
    case .textOnly:
        if case .text = item { return true }
        return false
    case .imagesOnly:
        if case .image = item { return true }
        return false
    }
}

extension ClipboardContent {
    var textRepresentation: String {
        switch self {
        case .text(let t):
            return t
        case .image(_):
            return "Image"
        }
    }
}
