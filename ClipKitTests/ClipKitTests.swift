//
//  ClipKitTests.swift
//  ClipKitTests
//
//  Created by Adheesh Saxena on 12/24/24.
//

import Testing
@testable import ClipKit

struct ClipKitTests {

    @Test func unpinItemTrimsEphemeralToMaxCount() async throws {
        // Setup: Create manager with a low maxEphemeralCount
        let settings = SettingsManager()
        let maxCount = 3
        settings.maxEphemeralCount = maxCount

        let manager = ClipboardManager(settings: settings)

        // Clear any persisted state loaded from disk
        manager.ephemeralItems.removeAll()
        manager.pinnedItems.removeAll()

        // Fill ephemeral items to max capacity
        for i in 0..<maxCount {
            let item = ClipboardItem(content: .text("ephemeral-\(i)"))
            manager.ephemeralItems.append(item)
        }
        #expect(manager.ephemeralItems.count == maxCount)

        // Create and add a pinned item
        let pinnedItem = ClipboardItem(content: .text("pinned-item"))
        manager.pinnedItems.append(pinnedItem)
        #expect(manager.pinnedItems.count == 1)

        // Unpin the item - this should add to ephemeral and trim
        manager.unpinItem(pinnedItem)

        // Assert: ephemeral count should not exceed maxCount
        #expect(manager.ephemeralItems.count <= maxCount,
                "Ephemeral items exceeded max count after unpin: \(manager.ephemeralItems.count) > \(maxCount)")
        #expect(manager.pinnedItems.count == 0, "Pinned item should be removed")

        // Verify the unpinned item is at the top
        #expect(manager.ephemeralItems.first?.content == .text("pinned-item"),
                "Unpinned item should be at the top of ephemeral list")
    }

    @Test func unpinItemWithZeroMaxCountDropsItem() async throws {
        // Edge case: maxEphemeralCount == 0 should immediately drop the item
        let settings = SettingsManager()
        settings.maxEphemeralCount = 0

        let manager = ClipboardManager(settings: settings)

        // Clear any persisted state loaded from disk
        manager.ephemeralItems.removeAll()
        manager.pinnedItems.removeAll()

        // Add a pinned item
        let pinnedItem = ClipboardItem(content: .text("will-be-dropped"))
        manager.pinnedItems.append(pinnedItem)

        // Unpin - item gets added then immediately trimmed
        manager.unpinItem(pinnedItem)

        #expect(manager.ephemeralItems.count == 0,
                "With maxEphemeralCount=0, ephemeral should be empty after unpin")
        #expect(manager.pinnedItems.count == 0)
    }

}
