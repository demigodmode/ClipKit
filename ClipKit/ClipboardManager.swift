//
//  ClipboardManager.swift
//  ClipKit
//
//  Created by Adheesh Saxena on 12/24/24.
//

import SwiftUI
import AppKit
import Darwin

// MARK: - ClipboardContent Enum
enum ClipboardContent: Equatable, Identifiable, Codable {
    case text(String)
    case image(Data)
    
    var id: String {
        switch self {
        case .text(let t):
            return "text-\(t.hashValue)"
        case .image(let data):
            return "image-\(data.hashValue)"
        }
    }
    
    // MARK: - Helper for Searching
    /// Returns `true` if this item's content matches the given `query` string.
    /// By default, text is searched case-insensitively, and images do not match.
    func matchesSearch(_ query: String) -> Bool {
        // If the query is empty, treat it as "matches everything"
        guard !query.isEmpty else { return true }
        
        switch self {
        case .text(let t):
            return t.localizedCaseInsensitiveContains(query)
        case .image(_):
            // You could return true if you want images to appear for certain keywords,
            // or store some metadata. For now, let's exclude images.
            return false
        }
    }
    
    // MARK: - Codable Support
    private enum CodingKeys: String, CodingKey {
        case caseType
        case textValue
        case imageData
    }
    
    private enum CaseType: String, Codable {
        case text
        case image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let caseType = try container.decode(CaseType.self, forKey: .caseType)
        switch caseType {
        case .text:
            let t = try container.decode(String.self, forKey: .textValue)
            self = .text(t)
        case .image:
            let d = try container.decode(Data.self, forKey: .imageData)
            self = .image(d)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let t):
            try container.encode(CaseType.text, forKey: .caseType)
            try container.encode(t, forKey: .textValue)
        case .image(let data):
            try container.encode(CaseType.image, forKey: .caseType)
            try container.encode(data, forKey: .imageData)
        }
    }
}

// MARK: - ClipboardManager Class
class ClipboardManager: ObservableObject {
    // MARK: - Published Properties
    
    // 1) Ephemeral (in-memory) that also saves to ephemeral.json
    @Published var ephemeralItems: [ClipboardContent] = []
    
    // 2) Pinned items (persisted to pinnedItems.json)
    @Published var pinnedItems: [ClipboardContent] = []
    
    private let maxPinnedCount = 12  // Allow up to 12 pinned items
    
    // MARK: - File URLs
    private let pinnedFileURL: URL
    private let ephemeralFileURL: URL
    
    // We'll store ephemeral items in ephemeral.json, along with the current bootTime
    // e.g., ephemeralContainer = { bootTime: 1691234567, items: [ClipboardContent...] }
    
    // MARK: - Timer for Pasteboard Polling
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    private var timer: Timer?
    
    // We record the current system boot time at launch.
    private let currentBootTime: TimeInterval
    
    init() {
        // 1. Grab current system boot time
        currentBootTime = fetchSystemBootTime() ?? 0
        
        // 2. Setup file URLs
        let fm = FileManager.default
        if let appSupport = try? fm.url(for: .applicationSupportDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: true) {
            pinnedFileURL = appSupport.appendingPathComponent("pinnedItems.json")
            ephemeralFileURL = appSupport.appendingPathComponent("ephemeralItems.json")
        } else {
            // Fallback to temp if we can't get Application Support
            pinnedFileURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("pinnedItems.json")
            ephemeralFileURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("ephemeralItems.json")
        }
        
        // 3. Load pinned + ephemeral
        loadPinnedItems()
        loadEphemeralItems()
        
        // 4. Start the timer for pasteboard polling
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(checkPasteboard),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Pasteboard Polling for Ephemeral Copies
    @objc private func checkPasteboard() {
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            
            // Read text
            if let copiedString = pasteboard.string(forType: .string) {
                let newItem = ClipboardContent.text(copiedString)
                if ephemeralItems.first != newItem {
                    ephemeralItems.insert(newItem, at: 0)
                    saveEphemeralItems()  // Save after each change
                }
            }
            // Read image
            else if let imageData = pasteboard.data(forType: .tiff) {
                let newItem = ClipboardContent.image(imageData)
                if ephemeralItems.first != newItem {
                    ephemeralItems.insert(newItem, at: 0)
                    saveEphemeralItems()
                }
            }
            // ignoring other data types for brevity
        }
    }
    
    // MARK: - Re-Copy
    func restoreToPasteboard(_ content: ClipboardContent) {
        pasteboard.clearContents()
        
        switch content {
        case .text(let t):
            pasteboard.setString(t, forType: .string)
        case .image(let data):
            pasteboard.setData(data, forType: .tiff)
        }
        
        // Move to top if in ephemeral
        if let idx = ephemeralItems.firstIndex(of: content) {
            ephemeralItems.remove(at: idx)
            ephemeralItems.insert(content, at: 0)
            saveEphemeralItems()
        }
        // pinned logic remains unchanged
    }
    
    // MARK: - Pin / Unpin
    func pinItem(_ content: ClipboardContent) {
        if pinnedItems.contains(content) {
            return
        }
        if pinnedItems.count >= maxPinnedCount {
            return
        }
        // remove from ephemeral if present
        if let idx = ephemeralItems.firstIndex(of: content) {
            ephemeralItems.remove(at: idx)
            saveEphemeralItems()
        }
        
        pinnedItems.insert(content, at: 0)
        savePinnedItems()
    }
    
    func unpinItem(_ content: ClipboardContent) {
        if let idx = pinnedItems.firstIndex(of: content) {
            pinnedItems.remove(at: idx)
            // optionally, re-add to ephemeral
            ephemeralItems.insert(content, at: 0)
            savePinnedItems()
            saveEphemeralItems()
        }
    }

    // MARK: - Clear Ephemeral Items
    func clearEphemeralItems() {
        ephemeralItems.removeAll()
        saveEphemeralItems()
    }

    // MARK: - Save / Load Pinned Items
    private func savePinnedItems() {
        do {
            let data = try JSONEncoder().encode(pinnedItems)
            try data.write(to: pinnedFileURL, options: .atomic)
        } catch {
            print("Failed to save pinned items:", error)
        }
    }
    
    private func loadPinnedItems() {
        do {
            let data = try Data(contentsOf: pinnedFileURL)
            let decoded = try JSONDecoder().decode([ClipboardContent].self, from: data)
            pinnedItems = decoded
        } catch {
            pinnedItems = []
        }
    }
    
    // MARK: - Save / Load Ephemeral Items
    private func saveEphemeralItems() {
        let ephemeralContainer = EphemeralContainer(bootTime: currentBootTime,
                                                    items: ephemeralItems)
        do {
            let data = try JSONEncoder().encode(ephemeralContainer)
            try data.write(to: ephemeralFileURL, options: .atomic)
        } catch {
            print("Failed to save ephemeral items:", error)
        }
    }
    
    private func loadEphemeralItems() {
        do {
            let data = try Data(contentsOf: ephemeralFileURL)
            let container = try JSONDecoder().decode(EphemeralContainer.self, from: data)
            // If the saved container has same bootTime, restore ephemeral. Otherwise, discard.
            if container.bootTime == currentBootTime {
                ephemeralItems = container.items
            } else {
                ephemeralItems = []
                try? FileManager.default.removeItem(at: ephemeralFileURL)
            }
        } catch {
            ephemeralItems = []
        }
    }
}

// MARK: - Helper Struct for Ephemeral Storage
private struct EphemeralContainer: Codable {
    let bootTime: TimeInterval
    let items: [ClipboardContent]
}

// MARK: - Boot Time Helper
private func fetchSystemBootTime() -> TimeInterval? {
    // We'll use sysctl to get kern.boottime
    var mib = [CTL_KERN, KERN_BOOTTIME]
    var bootTime = timeval()
    var size = MemoryLayout<timeval>.stride
    
    if sysctl(&mib, 2, &bootTime, &size, nil, 0) != -1 {
        return TimeInterval(bootTime.tv_sec)
    }
    return nil
}
