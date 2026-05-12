//
//  RegionsFetcher.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//


import Foundation

final class RegionsFetcher {
    
    func fetchRegions() async throws -> [Region] {
        let url = Bundle.main.url(forResource: "regions", withExtension: "xml")!
        let data = try Data(contentsOf: url)
        
        let regionsList = try RegionsXMLParser().parse(data: data)
        
        return regionsList.regions
    }

}
