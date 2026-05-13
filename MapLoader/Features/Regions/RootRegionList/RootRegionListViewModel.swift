//
//  RegionListViewModel.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//

import Foundation

final class RootRegionListViewModel: RegionListProviding {

    var tableViewDataSource: SectionedListTableViewDataSource! {
        listDataSource
    }
    var listDataSource: RootRegionListTableDataSource!
    let title = L10n.rootRegionTitle
    
    let downloader: SerialFileDownloader
    weak var coordinator: RegionsCoordinator!
    
    
    private let mapsProvider: MapsProvider
    let storageInfoProvider: StorageInfoProvider
    private var model = RootRegionListModel()
    
    var downloadProgressObserver: NSObjectProtocol? = nil
    private var storageInfoTask: Task<Void, Never>?
    
    private let byteFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 2
        return formatter
    }()
    
    init(
        mapsProvider: MapsProvider,
        storageInfoProvider: StorageInfoProvider,
        downloader: SerialFileDownloader,
        coordinator: RegionsCoordinator
    ) {
        self.mapsProvider = mapsProvider
        self.storageInfoProvider = storageInfoProvider
        self.downloader = downloader
        self.coordinator = coordinator
        self.listDataSource = RootRegionListTableDataSource(viewModel: self)
        loadData()
    }
    
    func loadData() {
        let storageInfo = try? storageInfoProvider.currentStorageInfo()
        model.storageInfo = storageInfo
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            let maps = await mapsProvider.getMaps()
            model.maps = maps
            
            listDataSource.update(data: model.maps)
            subscribeToDataUpdates()
        }
    }
    
    func subscribeToDataUpdates() {
        downloadProgressObserver = NotificationCenter.default.addObserver(
            forName: SerialFileDownloader.downloadingAdvancedNotification,
            object: nil,
            queue: .main
        ) { [weak tableViewDataSource] notification in
            tableViewDataSource?.updateVisibleRows()
        }
        
        storageInfoTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await info in storageInfoProvider.storageInfoStream(interval: .seconds(2)) {
                model.storageInfo = try? info.get()
                listDataSource.updateDeviceMemoryInfo()
            }
        }
    }
    
    func configureDeviceMemoryCell(_ cell: MemoryInfoTableViewCell) {
        let freeSpace = model.storageInfo?.availableSpace
        let freeSpaceString = freeSpace.map { byteFormatter.string(from: $0) }
        let summary = freeSpaceString.map { L10n.freeSpaceValue($0) } ?? ""
        let viewModel = MemoryInfoTableViewCell.ViewModel(title: L10n.deviceMemory, summary: summary, occupiedMemoryFraction: model.fractionSpaceTaken)
        
        cell.apply(viewModel: viewModel)
    }
    
    func findRegion(byId id: String) -> MapModel? {
        for region in model.maps {
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
