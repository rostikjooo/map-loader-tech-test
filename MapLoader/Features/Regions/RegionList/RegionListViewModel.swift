//
//  SubregionListViewModel.swift
//  MapLoader
//
//  Created by Rost on 13.05.2026.
//

import UIKit

class RegionListViewModel: RegionListProviding {
    var tableViewDataSource: SectionedListTableViewDataSource! {
        listDataSource
    }
    lazy var listDataSource = RegionListTableDataSource(viewModel: self)
    var title: String {
        model.name.capitalized
    }
    let downloader: SerialFileDownloader
    weak var coordinator: RegionsCoordinator!
    
    private var model: MapModel
    
    var downloadProgressObserver: NSObjectProtocol? = nil
    
    init(
        model: MapModel,
        downloader: SerialFileDownloader,
        coordinator: RegionsCoordinator
    ) {
        self.downloader = downloader
        self.model = model
        self.coordinator = coordinator
        loadData()
    }
    
    func loadData() {
        listDataSource.update(data: model.childs)
        subscribeToDataUpdates()
    }
    
    func subscribeToDataUpdates() {
        downloadProgressObserver = NotificationCenter.default.addObserver(
            forName: SerialFileDownloader.downloadingAdvancedNotification,
            object: nil,
            queue: .main
        ) { [weak tableViewDataSource] notification in
            tableViewDataSource?.updateVisibleRows()
        }
    }
    
    func findRegion(byId id: String) -> MapModel? {
        for region in model.childs {
            if region.id == id {
                return region
            }
            let found = region.childs.first { $0.id == id }
            if let found {
                return found
            }
        }
        return nil
    }
}
