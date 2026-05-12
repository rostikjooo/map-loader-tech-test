//
//  OsmAndDownloadURLBuilder.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import Foundation

struct OsmAndDownloadURLBuilder {
    private let baseURL = URL(string: "https://download.osmand.net/download")!

    func mapFileName(
        for region: Region,
        parent: Region?,
        continentName: String
    ) -> String? {
        guard isMapDownloadAvailable(for: region) else { return nil }

        let mapName = mapName(
            for: region,
            parent: parent,
            continentName: continentName
        )

        return "\(mapName.capitalizingFirstLetter())_2.obf.zip"
    }

    func mapDownloadURL(
        for region: Region,
        parent: Region?,
        continentName: String
    ) -> URL? {
        guard let fileName = mapFileName(
            for: region,
            parent: parent,
            continentName: continentName
        ) else { return nil }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "file", value: fileName)
        ]

        return components.url
    }

    private func isMapDownloadAvailable(for region: Region) -> Bool {
        return region.type == .map && region.map ?? true
    }

    private func mapName(
        for region: Region,
        parent: Region?,
        continentName: String
    ) -> String {
        if let prefix = parent?.innerDownloadPrefix {
            let resolvedPrefix = prefix.replacingOccurrences(
                of: "$name",
                with: parent?.name ?? ""
            )

            return "\(resolvedPrefix)_\(region.name)_\(continentName)"
        }

        if let parent {
            return "\(parent.name)_\(region.name)_\(continentName)"
        }

        return "\(region.name)_\(continentName)"
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
