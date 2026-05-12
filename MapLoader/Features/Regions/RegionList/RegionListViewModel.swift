//
//  RegionListViewModel.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//

import Foundation

struct RegionListModel {
    var storageInfo: StorageInfoProvider.StorageInfo?
    var maps: [MapModel] = []
    
    var fractionSpaceTaken: CGFloat {
        guard let storageInfo, let totalSpace = storageInfo.totalSpace else { return 0 }
        let availableSpace = storageInfo.availableSpace
        let fractionAvailable = availableSpace.converted(to: .bytes).value / totalSpace.converted(to: .bytes).value
        
        let fractionTaken = 1 - fractionAvailable
        
        return CGFloat(fractionTaken)
    }
}

final class RegionListViewModel {
    let title = "Download Maps"
    lazy var tableViewDataSource = RootRegionListTableDataSource(viewModel: self)
    
    private let mapsProvider: MapsProvider
    private let storageInfoProvider: StorageInfoProvider
    private let downloader: SerialFileDownloader
    
    private var model = RegionListModel()
    
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
        downloader: SerialFileDownloader
    ) {
        self.mapsProvider = mapsProvider
        self.storageInfoProvider = storageInfoProvider
        self.downloader = downloader
        
        loadData()
    }
    
    func loadData() {
        let storageInfo = try? storageInfoProvider.currentStorageInfo()
        model.storageInfo = storageInfo
        tableViewDataSource.update(data: [])
    }
    
    func configureDeviceMemoryCell(_ cell: MemoryInfoTableViewCell) {
        let freeSpace = model.storageInfo?.availableSpace
        let freeSpaceString = freeSpace.map { byteFormatter.string(from: $0) }
        let summary = freeSpaceString.map { "Free \($0)" } ?? ""
        let viewModel = MemoryInfoTableViewCell.ViewModel(title: "Device memory", summary: summary, occupiedMemoryFraction: model.fractionSpaceTaken)
        
        cell.apply(viewModel: viewModel)
    }
    
    func configureRegionCell(cell: RegionTableViewCell, byId: String) {
        let status: RegionTableViewCell.ViewModel.Status = [.loaded, .loading(progress: 0.3), .notLoaded].randomElement()!
        let viewModel = RegionTableViewCell.ViewModel(name: "Test", status: status)
        cell.apply(viewModel: viewModel)
    }
    
    func configureRegionNodeCell(cell: RegionNodeTableViewCell, byId: String) {
        cell.apply(name: "Node test")
    }
}
