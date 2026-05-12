//
//  RegionListTableDataSource.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//


import UIKit

class RegionListTableDataSource: SectionedListTableViewDataSource {
    
    weak var viewModel: RegionListViewModel!
    
    override var sections: [Section] {
        regionSections
    }
    
    override var rows: [[Row]] {
        regionRows
    }
    
    final var regionSections: [Section] = []
    final var regionRows: [[Row]] = []
    
    init(viewModel: RegionListViewModel) {
        self.viewModel = viewModel
    }
    
    override func registerCells(in tableView: UITableView) {
        super.registerCells(in: tableView)
        // TODO: register cells
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "deviceMemoryCell")
    }
    
    final func update(data: Data) {
        defer {
            reloadTable()
        }
        regionSections = [.init(id: "Q", name: "Europe")]
        regionRows = [[regionRow(id: "Q1"), regionNode(id: "Q2"), regionRow(id: "Q3")]]
    }
    
    private func regionRow(id: String) -> Row {
        Row(
            id: id,
            reuseIdentifier: "regionRowCell",
            configure: { [weak viewModel] cell in
                viewModel?.configureRegionCell(cell: cell, byId: id)
            }
        )
    }
    
    private func regionNode(id: String) -> Row {
        Row(
            id: id,
            reuseIdentifier: "regionNodeCell",
            configure: { [weak viewModel] cell in
                viewModel?.configureRegionNodeCell(cell: cell, byId: id)
            }
        )
    }
}
