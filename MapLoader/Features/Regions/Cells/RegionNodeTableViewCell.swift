//
//  RegionNodeTableViewCell.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import UIKit

class RegionNodeTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImage: UIImageView?
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var chevronImage: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }
    
    private func setupAppearance() {
        iconImage?.tintColor = .iconDefault
        chevronImage?.tintColor = .iconDefault
        label?.font = .preferredFont(forTextStyle: .body)
        label?.textColor = .textPrimary
    }
    
    func apply(name: String) {
        label?.text = name
    }
    
}
