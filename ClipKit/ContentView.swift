//
//  ContentView.swift
//  ClipKit
//
//  Created by Adheesh Saxena on 12/24/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @EnvironmentObject var settingsManager: SettingsManager

    // Search query is local state (not persisted)
    @State private var searchQuery = ""

    // Computed properties to convert between enum and stored string
    private var sortMode: SortMode {
        get { settingsManager.sortModeEnum }
        nonmutating set { settingsManager.sortModeEnum = newValue }
    }

    private var dataTypeFilter: DataTypeFilter {
        get { settingsManager.dataTypeFilterEnum }
        nonmutating set { settingsManager.dataTypeFilterEnum = newValue }
    }

    var body: some View {
        // The main pinned + ephemeral UI
        content
            .toolbar {
                // Put *all* items in one group. We add a Spacer() before the search field
                // so the search bar appears on the far right side of the toolbar.
                ToolbarItemGroup(placement: .automatic) {
                    // Sort mode
                    Picker("Sort By", selection: Binding(
                        get: { sortMode },
                        set: { sortMode = $0 }
                    )) {
                        ForEach(SortMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    // Data type filter
                    Picker("Data Type", selection: Binding(
                        get: { dataTypeFilter },
                        set: { dataTypeFilter = $0 }
                    )) {
                        ForEach(DataTypeFilter.allCases, id: \.self) { filter in
                            Text(filter.displayName).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    // Toggle grouping ephemeral by type
                    Toggle("Group By Type", isOn: $settingsManager.groupEphemeralByType)

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
            Text("Pinned (\(clipboardManager.pinnedItems.count)/\(settingsManager.maxPinnedCount))")
                .font(.headline)

            let filteredPinned = clipboardManager.pinnedItems
                .filter { $0.content.matchesSearch(searchQuery) }
                .filter { dataTypeFilterAllows($0.content, filter: dataTypeFilter) }
            let sortedPinned = sortClipboardItems(filteredPinned, by: sortMode)

            if sortedPinned.isEmpty {
                Text("No pinned items match your search/filter.")
                    .foregroundColor(.secondary)
            } else {
                // Only enable drag-and-drop reordering when viewing in natural order (most recent)
                // Dragging in sorted views would be confusing since items would jump after re-sorting
                let allowReorder = sortMode == .recent
                List {
                    ForEach(sortedPinned, id: \.id) { item in
                        ClipboardItemRow(item: item, pinned: true)
                            .onDrag {
                                guard allowReorder else { return NSItemProvider() }
                                return NSItemProvider(object: item.id.uuidString as NSString)
                            }
                            .onDrop(of: allowReorder ? [.text] : [], delegate: PinnedItemDropDelegate(
                                item: item,
                                getItems: { clipboardManager.pinnedItems },
                                onMove: { from, to in
                                    clipboardManager.movePinnedItems(from: from, to: to)
                                }
                            ))
                    }
                }
                .frame(minHeight: 100)
            }

            Divider().padding(.vertical, 8)

            // ----- Ephemeral Section -----
            HStack {
                Text("Recent (Ephemeral)")
                    .font(.headline)
                Spacer()
                Button(action: { clipboardManager.clearEphemeralItems() }) {
                    Text("Clear")
                }
                .buttonStyle(.bordered)
                .disabled(clipboardManager.ephemeralItems.isEmpty)
            }

            let filteredEphemeral = clipboardManager.ephemeralItems
                .filter { $0.content.matchesSearch(searchQuery) }
                .filter { dataTypeFilterAllows($0.content, filter: dataTypeFilter) }
            let sortedEphemeral = sortClipboardItems(filteredEphemeral, by: sortMode)

            // Group ephemeral by data type if toggled
            if settingsManager.groupEphemeralByType {
                let textItems = sortedEphemeral.filter { if case .text = $0.content { return true } else { return false } }
                let imageItems = sortedEphemeral.filter { if case .image = $0.content { return true } else { return false } }

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
    let item: ClipboardItem
    let pinned: Bool

    @EnvironmentObject var manager: ClipboardManager

    @State private var showFlash = false

    var isTopEphemeral: Bool {
        guard let first = manager.ephemeralItems.first else { return false }
        return first == item
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                switch item.content {
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

                Text(item.timestamp.relativeFormatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if pinned {
                Button(action: { manager.unpinItem(item) }) {
                    Image(systemName: "pin.slash.fill")
                }
                .buttonStyle(BorderlessButtonStyle())

                Button(action: { manager.deletePinnedItem(item) }) {
                    Image(systemName: "trash")
                }
                .buttonStyle(BorderlessButtonStyle())
            } else {
                Button(action: { manager.pinItem(item) }) {
                    Image(systemName: "pin")
                }
                .buttonStyle(BorderlessButtonStyle())

                Button(action: { manager.deleteEphemeralItem(item) }) {
                    Image(systemName: "trash")
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
func sortClipboardItems(_ items: [ClipboardItem], by mode: SortMode) -> [ClipboardItem] {
    switch mode {
    case .recent:
        return items
    case .alphabetical:
        return items.sorted {
            $0.content.textRepresentation.localizedCaseInsensitiveCompare($1.content.textRepresentation) == .orderedAscending
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

// MARK: - Date Formatting
extension Date {
    func relativeFormatted() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - Drag and Drop Delegate for Pinned Items
struct PinnedItemDropDelegate: DropDelegate {
    let item: ClipboardItem
    let getItems: () -> [ClipboardItem]  // Closure to get live items, not a snapshot
    let onMove: (IndexSet, Int) -> Void

    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedID = info.itemProviders(for: [.text]).first else { return }

        draggedID.loadObject(ofClass: NSString.self) { reading, _ in
            guard let uuidString = reading as? String,
                  let draggedUUID = UUID(uuidString: uuidString) else { return }

            DispatchQueue.main.async {
                let currentItems = getItems()  // Get current items at move time
                guard let fromIndex = currentItems.firstIndex(where: { $0.id == draggedUUID }),
                      let toIndex = currentItems.firstIndex(where: { $0.id == item.id }),
                      fromIndex != toIndex else { return }

                let destination = fromIndex < toIndex ? toIndex + 1 : toIndex
                onMove(IndexSet(integer: fromIndex), destination)
            }
        }
    }
}
