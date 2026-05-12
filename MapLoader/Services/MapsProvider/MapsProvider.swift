//
//  MapsProvider.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import Foundation

final class MapsProvider {
    private let regionsFetcher: RegionsFetcher
    private let urlBuilder: OsmAndDownloadURLBuilder
    private let downloader: SerialFileDownloader
    private let lock = NSLock()
    private var mapsTask: Task<[MapModel], Error>?
    
    init(regionsFetcher: RegionsFetcher, urlBuilder: OsmAndDownloadURLBuilder, downloader: SerialFileDownloader) {
        self.regionsFetcher = regionsFetcher
        self.urlBuilder = urlBuilder
        self.downloader = downloader
    }
    
    func getMaps() async -> [MapModel] {
        let task = getOrCreateMapsTask()

        do {
            return try await task.value
        } catch {
            clearMapsTask()
            return []
        }
    }

    private func getOrCreateMapsTask() -> Task<[MapModel], Error> {
        lock.lock()
        defer { lock.unlock() }

        if let mapsTask {
            return mapsTask
        }

        let task = Task<[MapModel], Error> { [weak self] in
            guard let self else { return [] }
            return try await self.fetchMaps()
        }

        mapsTask = task
        return task
    }

    private func clearMapsTask() {
        lock.lock()
        defer { lock.unlock() }

        mapsTask = nil
    }
    
    private func fetchMaps()  async throws -> [MapModel] {
        
        let regions = try await regionsFetcher.fetchRegions()
        
        let maps = regions.map { region in
            mapModel(
                for: region,
                regionPath: []
            )
        }
        
        return maps
    }
    
    private func mapModel(
        for region: Region,
        regionPath: [Region]
    ) -> MapModel {
        let currentRegionPath = regionPath + [region]
        
        let sourceURL = urlBuilder.mapDownloadURL(
            for: region,
            path: currentRegionPath
        )
        
        let currentPath = currentRegionPath.map(\.name)
        let childs = region.children.map { child in
            mapModel(
                for: child,
                regionPath: currentRegionPath
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


struct MapModel: Sendable {
    let name: String
    let path: [String]
    let sourceURL: URL?
    let childs: [MapModel]
    let isDownloaded: Bool
}
