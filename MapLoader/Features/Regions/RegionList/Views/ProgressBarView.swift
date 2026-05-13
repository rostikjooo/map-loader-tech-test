//
//  ProgressBarView.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import UIKit

final class SegmentedProgressBarView: UIView {

    typealias Segment = (fraction: CGFloat, color: UIColor)

    var trackColor: UIColor = .systemGray5 {
        didSet {
            backgroundColor = trackColor
        }
    }

    var cornerRadius: CGFloat = 4 {
        didSet {
            layer.cornerRadius = cornerRadius
            segmentViews.forEach { $0.layer.cornerRadius = cornerRadius }
        }
    }

    private var segments: [Segment] = []
    private var segmentViews: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func configure(with segments: [Segment], animated: Bool) {
        self.segments = normalized(segments)

        segmentViews.forEach { $0.removeFromSuperview() }

        segmentViews = self.segments.map { segment in
            let view = UIView()
            view.backgroundColor = segment.color
            view.layer.cornerRadius = cornerRadius
            view.clipsToBounds = true
            addSubview(view)
            return view
        }

        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = cornerRadius
        clipsToBounds = true

        var currentX: CGFloat = 0

        for (index, segment) in segments.enumerated() {
            let width = bounds.width * segment.fraction

            segmentViews[index].frame = CGRect(
                x: currentX,
                y: 0,
                width: width,
                height: bounds.height
            )

            currentX += width
        }
    }

    private func setup() {
        backgroundColor = trackColor
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
    }

    private func normalized(_ segments: [Segment]) -> [Segment] {
        let cleaned = segments
            .map { segment in
                (
                    fraction: min(max(segment.fraction, 0), 1),
                    color: segment.color
                )
            }
            .filter { $0.fraction > 0 }

        let total = cleaned.reduce(CGFloat.zero) { $0 + $1.fraction }

        guard total > 1 else {
            return cleaned
        }

        return cleaned.map {
            (fraction: $0.fraction / total, color: $0.color)
        }
    }
}
