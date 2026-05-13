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
    
    var getVisibleCell: (IndexPath) -> UITableViewCell? = { _ in nil }
    var indexPathsForVisibleRows: () -> [IndexPath] = { [] }
    
    func registerCells(in tableView: UITableView) {}
    
    func updateItem(id: String) {
        guard let indexPath = findRowIndexPath(id: id),
              let cell = getVisibleCell(indexPath) else { return }
        
        let row = rows[indexPath.section][indexPath.row]
        row.configure(cell)
    }
    
    func updateVisibleRows() {
        let paths = indexPathsForVisibleRows()
        paths.forEach {
            guard let cell = getVisibleCell($0) else { return }
            rows[$0.section][$0.row].configure(cell)
        }
    }
    
    private func findRowIndexPath(id: String) -> IndexPath? {
        for (sectionIndex, section) in rows.enumerated() {
            let rowIndex = section.firstIndex {
                $0.id == id
            }
            if let rowIndex {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }
}

extension SectionedListTableViewDataSource {
    struct Section: Identifiable {
        let id: String
        let name: String?
    }

    struct Row: Identifiable {
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
