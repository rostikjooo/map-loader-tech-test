//
//  RegionListProviding.swift
//  MapLoader
//
//  Created by Rost on 13.05.2026.
//

import Foundation

protocol RegionListProviding: AnyObject {
    var title: String { get }
    var downloader: SerialFileDownloader { get }
    var coordinator: RegionsCoordinator! { get }
    var tableViewDataSource: SectionedListTableViewDataSource! { get }
    func findRegion(byId id: String) -> MapModel?
}

extension RegionListProviding {
    
    func configureRegionCell(cell: RegionTableViewCell, byId id: String) {
        guard let region = findRegion(byId: id), let sourceURL = region.sourceURL else {
            print("configureRegionCell: cell doesn't match model")
            return
        }
        
        var status: RegionTableViewCell.ViewModel.Status
        if downloader.isDownloaded(sourceURL: sourceURL) {
            status = .loaded
        } else if downloader.isQueued(sourceURL) {
            let progress = downloader.progressFor(sourceURL)
            status = .loading(progress: progress)
        } else {
            status = .notLoaded
        }
        let viewModel = RegionTableViewCell.ViewModel(name: region.name, status: status)
        cell.apply(viewModel: viewModel)
    }
    
    func configureRegionNodeCell(cell: RegionNodeTableViewCell, byId id: String) {
        guard let region = findRegion(byId: id), !region.childs.isEmpty else {
            print("configureRegionNodeCell: cell doesn't match model")
            return
        }
        cell.apply(name: region.name)
    }
    
    func didSelectRow(withId id: String) {
        guard let region = findRegion(byId: id) else {
            print("didSelectRow: cell doesn't match model")
            return
        }
        if !region.childs.isEmpty {
            coordinator.openSubregion(region)
        } else if let sourceURL = region.sourceURL, !downloader.isDownloaded(sourceURL: sourceURL) {
            if downloader.isQueued(sourceURL) {
                downloader.cancelDownload(sourceURL)
            } else {
                downloader.download(sourceURL)
            }
            
            tableViewDataSource.updateItem(id: region.id)
        }
    }
}

