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

    // Keyboard navigation state
    @State private var selectedItemID: UUID?
    @FocusState private var isSearchFocused: Bool

    // Computed properties to convert between enum and stored string
    private var sortMode: SortMode {
        get { settingsManager.sortModeEnum }
        nonmutating set { settingsManager.sortModeEnum = newValue }
    }

    private var dataTypeFilter: DataTypeFilter {
        get { settingsManager.dataTypeFilterEnum }
        nonmutating set { settingsManager.dataTypeFilterEnum = newValue }
    }

    /// All visible items in navigation order (pinned first, then ephemeral)
    private var allVisibleItems: [(item: ClipboardItem, isPinned: Bool)] {
        let filteredPinned = clipboardManager.pinnedItems
            .filter { $0.content.matchesSearch(searchQuery) }
            .filter { dataTypeFilterAllows($0.content, filter: dataTypeFilter) }
        let sortedPinned = sortClipboardItems(filteredPinned, by: sortMode)

        let filteredEphemeral = clipboardManager.ephemeralItems
            .filter { $0.content.matchesSearch(searchQuery) }
            .filter { dataTypeFilterAllows($0.content, filter: dataTypeFilter) }
        let sortedEphemeral = sortClipboardItems(filteredEphemeral, by: sortMode)

        return sortedPinned.map { ($0, true) } + sortedEphemeral.map { ($0, false) }
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
                        .focused($isSearchFocused)
                }
            }
            .background(KeyEventHandler(
                onUpArrow: { handleKeyNavigation(direction: .up) },
                onDownArrow: { handleKeyNavigation(direction: .down) },
                onReturn: { handleReturnKey() },
                onDelete: { handleDeleteKey() },
                onEscape: { handleEscapeKey() },
                onPin: { handlePinKey() }
            ))
    }

    // MARK: - Keyboard Navigation Helpers

    private enum NavigationDirection {
        case up, down
    }

    private func handleKeyNavigation(direction: NavigationDirection) {
        let items = allVisibleItems
        guard !items.isEmpty else { return }

        if let currentID = selectedItemID,
           let currentIndex = items.firstIndex(where: { $0.item.id == currentID }) {
            let newIndex: Int
            switch direction {
            case .up:
                newIndex = max(0, currentIndex - 1)
            case .down:
                newIndex = min(items.count - 1, currentIndex + 1)
            }
            selectedItemID = items[newIndex].item.id
        } else {
            // No selection, select first or last
            selectedItemID = direction == .down ? items.first?.item.id : items.last?.item.id
        }
    }

    private func handleReturnKey() {
        guard let selectedID = selectedItemID,
              let selected = allVisibleItems.first(where: { $0.item.id == selectedID }) else { return }
        clipboardManager.restoreToPasteboard(selected.item)
    }

    private func handleDeleteKey() {
        guard let selectedID = selectedItemID,
              let selected = allVisibleItems.first(where: { $0.item.id == selectedID }) else { return }

        // Move selection to next item before deleting
        let items = allVisibleItems
        if let currentIndex = items.firstIndex(where: { $0.item.id == selectedID }) {
            if currentIndex + 1 < items.count {
                selectedItemID = items[currentIndex + 1].item.id
            } else if currentIndex > 0 {
                selectedItemID = items[currentIndex - 1].item.id
            } else {
                selectedItemID = nil
            }
        }

        if selected.isPinned {
            clipboardManager.deletePinnedItem(selected.item)
        } else {
            clipboardManager.deleteEphemeralItem(selected.item)
        }
    }

    private func handleEscapeKey() {
        if isSearchFocused {
            isSearchFocused = false
            searchQuery = ""
        } else {
            selectedItemID = nil
        }
    }

    private func handlePinKey() {
        guard let selectedID = selectedItemID,
              let selected = allVisibleItems.first(where: { $0.item.id == selectedID }) else { return }

        if selected.isPinned {
            clipboardManager.unpinItem(selected.item)
        } else {
            clipboardManager.pinItem(selected.item)
        }
        // Clear selection since item moved between lists
        selectedItemID = nil
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
                        ClipboardItemRow(item: item, pinned: true, isSelected: selectedItemID == item.id)
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
                                    ClipboardItemRow(item: item, pinned: false, isSelected: selectedItemID == item.id)
                                }
                            }
                        }
                        if !imageItems.isEmpty {
                            Section(header: Text("Images")) {
                                ForEach(imageItems, id: \.id) { item in
                                    ClipboardItemRow(item: item, pinned: false, isSelected: selectedItemID == item.id)
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
                        ClipboardItemRow(item: item, pinned: false, isSelected: selectedItemID == item.id)
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
    let isSelected: Bool

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
                if isSelected {
                    Color.accentColor.opacity(0.2)
                } else if isTopEphemeral {
                    Color.yellow.opacity(0.15)
                }
                if showFlash {
                    Color.blue.opacity(0.2)
                }
            }
        )
        .animation(.easeInOut(duration: 0.3), value: showFlash)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
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

// MARK: - Keyboard Event Handler (macOS 13+ compatible)
struct KeyEventHandler: NSViewRepresentable {
    let onUpArrow: () -> Void
    let onDownArrow: () -> Void
    let onReturn: () -> Void
    let onDelete: () -> Void
    let onEscape: () -> Void
    let onPin: () -> Void

    func makeNSView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView()
        view.onUpArrow = onUpArrow
        view.onDownArrow = onDownArrow
        view.onReturn = onReturn
        view.onDelete = onDelete
        view.onEscape = onEscape
        view.onPin = onPin
        return view
    }

    func updateNSView(_ nsView: KeyCaptureView, context: Context) {
        nsView.onUpArrow = onUpArrow
        nsView.onDownArrow = onDownArrow
        nsView.onReturn = onReturn
        nsView.onDelete = onDelete
        nsView.onEscape = onEscape
        nsView.onPin = onPin
    }
}

class KeyCaptureView: NSView {
    var onUpArrow: (() -> Void)?
    var onDownArrow: (() -> Void)?
    var onReturn: (() -> Void)?
    var onDelete: (() -> Void)?
    var onEscape: (() -> Void)?
    var onPin: (() -> Void)?

    private var localMonitor: Any?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupMonitor()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupMonitor()
    }

    private func setupMonitor() {
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }

            // Only handle if the window is key and no text field is first responder
            guard let window = self.window,
                  window.isKeyWindow else { return event }

            // Skip if user is typing in a text field
            if let firstResponder = window.firstResponder,
               firstResponder is NSTextView || firstResponder is NSTextField {
                // Allow escape to work even in text field
                if event.keyCode == 53 { // Escape
                    self.onEscape?()
                    return nil
                }
                return event
            }

            switch event.keyCode {
            case 126: // Up arrow
                self.onUpArrow?()
                return nil
            case 125: // Down arrow
                self.onDownArrow?()
                return nil
            case 36: // Return
                self.onReturn?()
                return nil
            case 51: // Delete/Backspace
                self.onDelete?()
                return nil
            case 117: // Forward Delete
                self.onDelete?()
                return nil
            case 53: // Escape
                self.onEscape?()
                return nil
            case 35: // P key
                self.onPin?()
                return nil
            default:
                return event
            }
        }
    }

    deinit {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
