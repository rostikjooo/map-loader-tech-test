//
//  RegionListTableDataSource.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//


import UIKit

class RegionListTableDataSource: SectionedListTableViewDataSource {
    
    weak var viewModel: RegionListProviding!
    
    override var sections: [Section] {
        regionSections
    }
    
    override var rows: [[Row]] {
        regionRows
    }
    
    var regionSections: [Section] = []
    var regionRows: [[Row]] = []
    
    init(viewModel: RegionListProviding) {
        self.viewModel = viewModel
    }
    
    override func registerCells(in tableView: UITableView) {
        super.registerCells(in: tableView)
        tableView.register(
            UINib(nibName: "RegionNodeTableViewCell", bundle: nil),
            forCellReuseIdentifier: "RegionNodeTableViewCell"
        )
        tableView.register(
            UINib(nibName: "RegionTableViewCell", bundle: nil),
            forCellReuseIdentifier: "RegionTableViewCell"
        )
    }
    
    func update(data: [MapModel]) {
        defer {
            reloadTable()
        }
        let sectionRows = data.map { regionRow(region: $0) }
         
        regionSections = [Section(id: "first", name: nil)]
        regionRows = [sectionRows]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = rows[indexPath.section][indexPath.row]
        viewModel.didSelectRow(withId: row.id)
    }
    
    func regionRow(region: MapModel) -> Row {
        if region.childs.isEmpty {
            return regionRow(id: region.id)
        } else {
            return regionNode(id: region.id)
        }
    }
    
    func regionRow(id: String) -> Row {
        Row(
            id: id,
            reuseIdentifier: "RegionTableViewCell",
            configure: { [weak viewModel] cell in
                guard let cell = cell as? RegionTableViewCell else { return }
                viewModel?.configureRegionCell(cell: cell, byId: id)
            }
        )
    }
    
    func regionNode(id: String) -> Row {
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
