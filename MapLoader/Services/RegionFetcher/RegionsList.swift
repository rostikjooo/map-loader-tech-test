//
//  RegionsList.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import Foundation

struct RegionsList {
    var regions: [Region]
}

struct Region: Equatable {
    var type: RegionType?
    var name: String
    var translate: String?
    var lang: String?
    var boundary: Bool?
    var polyExtract: String?

    var map: Bool?
    var wiki: Bool?
    var roads: Bool?
    var srtm: Bool?
    var hillshade: Bool?

    var downloadPrefix: String?
    var downloadSuffix: String?
    var innerDownloadPrefix: String?
    var innerDownloadSuffix: String?
    var joinMapFiles: Bool?
    var joinRoadFiles: Bool?
    var leftHandNavigation: Bool?
    var metric: Bool?

    var children: [Region]
}

enum RegionType: String {
    case continent
    case map
    case srtm
    case hillshade
}
