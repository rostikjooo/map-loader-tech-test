//
//  MapsProvider.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import Foundation

final class MapsProvider {
    let regionsFetcher = RegionsFetcher()
    let urlBuilder = OsmAndDownloadURLBuilder()
    let downloader = SerialFileDownloader()
    
    func fetchMaps()  async throws -> [MapModel] {
        let regions = try await regionsFetcher.fetchRegions()
        
        let maps = regions.map { region in
            mapModel(
                for: region,
                parent: nil,
                continentName: region.name,
                path: []
            )
        }
        
        return maps
    }
    
    private func mapModel(
        for region: Region,
        parent: Region?,
        continentName: String,
        path: [String]
    ) -> MapModel {
        let sourceURL = urlBuilder.mapDownloadURL(
            for: region,
            parent: parent,
            continentName: continentName
        )
        
        let currentPath = path + [region.name]
        let childs = region.children.map { child in
            mapModel(
                for: child,
                parent: region,
                continentName: continentName,
                path: currentPath
            )
        }
        
        return MapModel(
            name: region.name,
            path: currentPath,
            sourceURL: sourceURL,
            childs: childs,
            isDownloaded: sourceURL.flatMap {
                downloader.downloadedFileLocationFor(sourceURL: $0)
            } != nil
        )
    }
}


struct MapModel {
    let name: String
    let path: [String]
    let sourceURL: URL?
    let childs: [MapModel]
    let isDownloaded: Bool
}
