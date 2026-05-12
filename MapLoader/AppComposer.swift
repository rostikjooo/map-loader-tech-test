//
//  AppComposer.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//

import UIKit

final class AppComposer {

    private var regionsCoordinator: RegionsCoordinator?
    let fileDownloader = SerialFileDownloader()
    let storageInfoProvider = StorageInfoProvider()
    lazy private(set) var mapsProvider: MapsProvider = {
        MapsProvider(
            regionsFetcher: RegionsFetcher(),
            urlBuilder: OsmAndDownloadURLBuilder(),
            downloader: fileDownloader
        )
    }()

    func makeRootVC() -> UIViewController {
        let regionsCoordinator = RegionsCoordinator(composer: self)
        regionsCoordinator.start()
        self.regionsCoordinator = regionsCoordinator

        return regionsCoordinator.navigationController
    }
}
