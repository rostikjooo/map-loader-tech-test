//
//  RegionTableViewCell.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import UIKit

class RegionTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImage: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var progressBarContainer: UIView?
    @IBOutlet weak var progressBar: SegmentedProgressBarView?
    @IBOutlet weak var downloadButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }

    private func setupAppearance() {
        iconImage?.tintColor = .iconDefault
        nameLabel?.font = .preferredFont(forTextStyle: .body)
        nameLabel?.textColor = .textPrimary
        progressBar?.trackColor = .tableSeparator
        progressBar?.cornerRadius = 3
    }
    
    func apply(viewModel: ViewModel) {
        nameLabel?.text = viewModel.name
        
        let iconColor: UIColor =
        if case .loaded = viewModel.status {
            .success
        } else {
            .iconDefault
        }
        iconImage?.tintColor = iconColor
        
        switch viewModel.status {
        case .loaded:
            downloadButton?.isHidden = true
        case .loading:
            downloadButton?.isHidden = false
            downloadButton?.setImage(.icCustomShowOnMap, for: .normal)
        case .notLoaded:
            downloadButton?.isHidden = false
            downloadButton?.setImage(.icCustomDownload, for: .normal)
        }
        
        switch viewModel.status {
        case .loaded:
            progressBarContainer?.isHidden = true
        case .notLoaded:
            progressBarContainer?.isHidden = true
        case .loading(let progress):
            progressBarContainer?.isHidden = false
            let progress = (fraction: progress, color: UIColor.activeDay)
            progressBar?.configure(with: [progress], animated: false)
        }
    }
    
}

extension RegionTableViewCell {
    struct ViewModel {
        let name: String
        let status: Status
        
        enum Status {
            case loaded
            case notLoaded
            case loading(progress: CGFloat)
        }
    }
}
