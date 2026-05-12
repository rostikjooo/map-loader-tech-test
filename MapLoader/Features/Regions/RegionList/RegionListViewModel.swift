//
//  RegionListViewModel.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//

import UIKit

final class RegionListViewModel {

    let title = "Download Maps"
    lazy var tableViewDataSource = RegionListTableDataSource(viewModel: self)

    
    func configureDeviceMemoryCell(_ cell: UITableViewCell) {
        
    }
    
    func configureRegionCell(cell: UITableViewCell, byId: String) {
        
    }
    
    func configureRegionNodeCell(cell: UITableViewCell, byId: String) {
        
    }
}
