//
//  L10n.swift
//  MapLoader
//
//  Created by Rost on 13.05.2026.
//

enum L10n {
    static var rootRegionTitle: String { "Download Maps" }
    static var deviceMemory: String { "Device memory" }
    static func freeSpaceValue(_ value: String) -> String {
        "Free \(value)"
    }
}
