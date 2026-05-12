//
//  RootRegionListTableDataSource.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//


import UIKit

class RootRegionListTableDataSource: RegionListTableDataSource {
    
    static let deviceMemorySection: Section = .init(id: "deviceMemory", name: "Device Memory")
    lazy var deviceMemoryRow: Row = .init(
        id: "deviceMemory",
        reuseIdentifier: "deviceMemoryCell",
        configure: { [weak self] cell in
            self?.viewModel.configureDeviceMemoryCell(cell)
        }
    )
    
    override var sections: [Section] {
        [Self.deviceMemorySection] + regionSections
    }
    
    override var rows: [[Row]] {
        [[deviceMemoryRow]] + regionRows
    }
    
    override func registerCells(in tableView: UITableView) {
        super.registerCells(in: tableView)
        // TODO: register cells
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "deviceMemoryCell")
    }
}
