//
//  OsmAndDownloadURLBuilder.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import Foundation

struct OsmAndDownloadURLBuilder {
    private let baseURL = URL(string: "https://download.osmand.net/download")!
    
    // FIXME: tell someone there is bug in XML and remove special func
    // <region name="nordrhein-westfalen" hillshade="no" inner_download_prefix="germany_nordrhein_westfalen" join_map_files="yes">
    // for that entry inner_download_prefix should be "germany_$name"
    let specialPlaceholderCases: [(name: String, innerDownloadPrefix: String, result: String)] = [
        (
            name: "nordrhein-westfalen",
            innerDownloadPrefix: "germany_nordrhein_westfalen",
            result: "germany_nordrhein-westfalen"
        )
    ]

    func mapFileName(
        for region: Region,
        path: [Region]
    ) -> String? {
        guard isMapDownloadAvailable(for: region) else { return nil }

        let mapName = mapName(
            for: region,
            path: path
        )

        return "\(mapName.capitalizingFirstLetter())_2.obf.zip"
    }

    func mapDownloadURL(
        for region: Region,
        path: [Region]
    ) -> URL? {
        guard let fileName = mapFileName(
            for: region,
            path: path
        ) else { return nil }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "file", value: fileName)
        ]

        return components.url
    }

    private func isMapDownloadAvailable(for region: Region) -> Bool {
        if region.map == false { return false }
        if region.map == true { return true }
        return region.type == .map
    }

    private func mapName(
        for region: Region,
        path: [Region]
    ) -> String {
        let ancestors = path.dropLast()
        let downloadPrefix = region.downloadPrefix
            .map { resolveNamePlaceholder(in: $0, with: region.name) }
            ?? inheritedDownloadPrefix(from: ancestors)
        let downloadSuffix = region.downloadSuffix
            .map { resolveNamePlaceholder(in: $0, with: region.name) }
            ?? inheritedDownloadSuffix(from: ancestors)

        return [
            downloadPrefix,
            region.name,
            downloadSuffix
        ]
        .compactMap { $0 }
        .joined(separator: "_")
    }
    
    private func inheritedDownloadPrefix(from ancestors: ArraySlice<Region>) -> String? {
        ancestors
            .reversed()
            .lazy
            .compactMap { ancestor in
                ancestor.innerDownloadPrefix.map {
                    resolveNamePlaceholder(in: $0, with: ancestor.name)
                }
            }
            .first
    }
    
    private func inheritedDownloadSuffix(from ancestors: ArraySlice<Region>) -> String? {
        ancestors
            .reversed()
            .lazy
            .compactMap { ancestor in
                (ancestor.innerDownloadSuffix ?? ancestor.downloadSuffix).map {
                    resolveNamePlaceholder(in: $0, with: ancestor.name)
                }
            }
            .first
    }
    
    private func resolveNamePlaceholder(in value: String, with name: String) -> String {
        if let specialCaseResult = findNameSpecialCases(value: value, name: name) {
            return specialCaseResult
        }
        return value.replacingOccurrences(of: "$name", with: name)
    }
    
    private func findNameSpecialCases(value: String, name: String) -> String? {
        let specialCase = specialPlaceholderCases.first {
            $0.name == name && $0.innerDownloadPrefix == value
        }
        return specialCase?.result
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
