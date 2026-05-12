//
//  SectionedListTableViewDataSource.swift
//  MapLoader
//
//  Created by Rost on 11.05.2026.
//


import UIKit

class SectionedListTableViewDataSource: NSObject {
    var sections: [Section] { [] }
    var rows: [[Row]] { [] }
    var reloadTable: () -> Void = { }
    
    func registerCells(in tableView: UITableView) {}
}

extension SectionedListTableViewDataSource {
    struct Section {
        let id: String
        let name: String?
    }

    struct Row {
        let id: String
        let reuseIdentifier: String
        let configure: (UITableViewCell) -> Void
    }
}

extension SectionedListTableViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].name
    }
}

extension SectionedListTableViewDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        row.configure(cell)
        
        return cell
    }
}
