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
        tableView.register(
            UINib(nibName: "RegionNodeTableViewCell", bundle: nil),
            forCellReuseIdentifier: "RegionNodeTableViewCell"
        )
        tableView.register(
            UINib(nibName: "RegionTableViewCell", bundle: nil),
            forCellReuseIdentifier: "RegionTableViewCell"
        )
    }
    
    final func update(data: [MapModel]) {
        defer {
            reloadTable()
        }
        
        regionRows = [
            [regionRow(id: "Q1"), regionNode(id: "Q2"), regionRow(id: "Q3")],
            [regionRow(id: "Qs1"), regionNode(id: "Qs2"), regionRow(id: "Qs3")],
            [regionRow(id: "Qs1"), regionNode(id: "Qs2"), regionRow(id: "Qs3")],
            [regionRow(id: "Qs1"), regionNode(id: "Qs2"), regionRow(id: "Qs3")],
            [regionRow(id: "Qs1"), regionNode(id: "Qs2"), regionRow(id: "Qs3")],
            [regionRow(id: "Qs1"), regionNode(id: "Qs2"), regionRow(id: "Qs3")],
            [regionRow(id: "Qs1"), regionNode(id: "Qs2"), regionRow(id: "Qs3")],
        ]
        regionSections = Array(
            repeating: .init(id: "Q", name: "Europe"),
            count: regionRows.count
        )
    }
    
    private func regionRow(id: String) -> Row {
        Row(
            id: id,
            reuseIdentifier: "RegionTableViewCell",
            configure: { [weak viewModel] cell in
                guard let cell = cell as? RegionTableViewCell else { return }
                viewModel?.configureRegionCell(cell: cell, byId: id)
            }
        )
    }
    
    private func regionNode(id: String) -> Row {
        Row(
            id: id,
            reuseIdentifier: "RegionNodeTableViewCell",
            configure: { [weak viewModel] cell in
                guard let cell = cell as? RegionNodeTableViewCell else { return }
                viewModel?.configureRegionNodeCell(cell: cell, byId: id)
            }
        )
    }
}
