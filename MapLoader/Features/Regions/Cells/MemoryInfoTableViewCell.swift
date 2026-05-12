//
//  MemoryInfoTableViewCell.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import UIKit

class MemoryInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var valueLabel: UILabel?
    @IBOutlet weak var progressBar: SegmentedProgressBarView?
    
    private let occupiedBarColor: UIColor = .memoryOccupied
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureAppearance()
    }
    
    func apply(viewModel: ViewModel) {
        titleLabel?.text = viewModel.title
        valueLabel?.text = viewModel.summary
        let occupiedSegment = SegmentedProgressBarView.Segment(
            fraction: viewModel.occupiedMemoryFraction,
            color: occupiedBarColor
        )
        progressBar?.configure(with: [occupiedSegment], animated: true)
    }
    
    private func configureAppearance() {
        contentView.backgroundColor = .backgroundWhiteGroup
        titleLabel?.font = .preferredFont(forTextStyle: .body)
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.textColor = .textPrimary
        
        valueLabel?.font = .preferredFont(forTextStyle: .body)
        valueLabel?.adjustsFontForContentSizeCategory = true
        valueLabel?.textColor = .textSecondary
        
        progressBar?.trackColor = .freeSpaceBackground
    }
    
}

extension MemoryInfoTableViewCell {
    struct ViewModel {
        let title: String
        let summary: String
        let occupiedMemoryFraction: CGFloat
    }
}
