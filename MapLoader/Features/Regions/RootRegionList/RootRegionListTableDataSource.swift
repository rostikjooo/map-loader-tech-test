//
//  RootRegionListTableDataSource.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//

import UIKit

class RootRegionListTableDataSource: RegionListTableDataSource {
    
    override var viewModel: RegionListProviding! {
        get { rootRegionViewModel }
        set { rootRegionViewModel = newValue as? RootRegionListViewModel }
    }
    weak var rootRegionViewModel: RootRegionListViewModel!
    
    override var sections: [Section] {
        [deviceMemorySection] + regionSections
    }
    
    override var rows: [[Row]] {
        [[deviceMemoryRow]] + regionRows
    }
    
    let deviceMemorySection: Section = .init(id: "deviceMemory", name: nil)
    lazy var deviceMemoryRow: Row = .init(
        id: "deviceMemory",
        reuseIdentifier: "MemoryInfoTableViewCell",
        configure: { [weak self] cell in
            guard let cell = cell as? MemoryInfoTableViewCell else { return }
            self?.rootRegionViewModel.configureDeviceMemoryCell(cell)
        }
    )
    
    required init(viewModel: RootRegionListViewModel!) {
        super.init(viewModel: viewModel)
        self.rootRegionViewModel = viewModel
    }
    
    override func registerCells(in tableView: UITableView) {
        super.registerCells(in: tableView)
        tableView.register(
            UINib(nibName: "MemoryInfoTableViewCell", bundle: nil),
            forCellReuseIdentifier: "MemoryInfoTableViewCell"
        )
    }
    
    override func update(data: [MapModel]) {
        defer {
            reloadTable()
        }
        
        var newSections: [Section] = []
        var newRows: [[Row]] = []
        var uncategorizedSectionRows = [Row]()
        
        for regionMap in data {
            guard !regionMap.childs.isEmpty else {
                uncategorizedSectionRows.append(regionRow(region: regionMap))
                continue
            }
            
            newSections.append(Section(id: regionMap.name, name: regionMap.name.capitalized))
            
            let newSectionRows = regionMap.childs.map { subregion in
                regionRow(region: subregion)
            }
            
            newRows.append(newSectionRows)
        }
        
        let uncotegorizedSection = Section(id: "uncotegorized regions", name: nil)
        
        if uncategorizedSectionRows.isEmpty {
            regionSections = newSections
            regionRows = newRows
        } else {
            regionSections = newSections + [uncotegorizedSection]
            regionRows = newRows + [uncategorizedSectionRows]
        }
    }
    
    func updateDeviceMemoryInfo() {
        let sectionIndex = sections.firstIndex { $0.id == deviceMemorySection.id } ?? 0
        let rowIndex = rows[sectionIndex].firstIndex { $0.id == deviceMemoryRow.id }
        guard let rowIndex, let cell = getVisibleCell(IndexPath(row: rowIndex, section: sectionIndex)) else { return }
        
        deviceMemoryRow.configure(cell)
    }
}
