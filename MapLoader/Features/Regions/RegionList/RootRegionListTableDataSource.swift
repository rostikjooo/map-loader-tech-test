//
//  RootRegionListTableDataSource.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//


import UIKit

class RootRegionListTableDataSource: RegionListTableDataSource {
    
    static let deviceMemorySection: Section = .init(id: "deviceMemory", name: nil)
    lazy var deviceMemoryRow: Row = .init(
        id: "deviceMemory",
        reuseIdentifier: "MemoryInfoTableViewCell",
        configure: { [weak self] cell in
            guard let cell = cell as? MemoryInfoTableViewCell else { return }
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
        tableView.register(
            UINib(nibName: "MemoryInfoTableViewCell", bundle: nil),
            forCellReuseIdentifier: "MemoryInfoTableViewCell"
        )
    }
}
