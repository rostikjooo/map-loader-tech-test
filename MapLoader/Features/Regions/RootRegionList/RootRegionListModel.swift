//
//  RegionListModel.swift
//  MapLoader
//
//  Created by Rost on 13.05.2026.
//

import Foundation

struct RootRegionListModel {
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
