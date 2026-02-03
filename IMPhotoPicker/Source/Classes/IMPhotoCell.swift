//
//  IMPhotoCell.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit
import Photos

// MARK: - PaddedLabel
class PaddedLabel: UILabel {
    var padding = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }
}

// MARK: - IMPhotoCell
class IMPhotoCell: UICollectionViewCell {
    var representedAssetIdentifier: String?
    static let reuseIdentifier = "IMPhotoCell"
    
    // MARK: - UI Properties
    
    public var badgeColor: UIColor = .systemBlue {
        didSet {
            badgeLabel.backgroundColor = badgeColor
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let selectionOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.4)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemBlue
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 1.5
        return label
    }()
    
    private let durationLabel: PaddedLabel = {
        let label = PaddedLabel()
        label.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = false
        label.clipsToBounds = true
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowRadius = 0.5
        label.layer.shadowOpacity = 0.8
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(selectionOverlay)
        contentView.addSubview(badgeLabel)
        contentView.addSubview(durationLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            selectionOverlay.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionOverlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectionOverlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionOverlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            badgeLabel.widthAnchor.constraint(equalToConstant: 24),
            badgeLabel.heightAnchor.constraint(equalToConstant: 24),
            badgeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            badgeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
        
        NSLayoutConstraint.activate([
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        representedAssetIdentifier = nil
        setSelectionOrder(nil)
        setVideoDuration(nil)
    }
    
    // MARK: - Public Methods
    func setSelectionOrder(_ order: Int?) {
        if let order = order {
            selectionOverlay.isHidden = false
            badgeLabel.isHidden = false
            badgeLabel.text = "\(order)"
        } else {
            selectionOverlay.isHidden = true
            badgeLabel.isHidden = true
        }
    }
    
    func setVideoDuration(_ duration: TimeInterval?) {
        if let duration = duration {
            durationLabel.text = formatTimeInterval(duration)
            durationLabel.isHidden = false
        } else {
            durationLabel.isHidden = true
        }
    }
    
    // MARK: - Private Methods
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

extension IMPhotoCell {
    /// Updates video duration display based on selection status.
    func updateVideoDuration(for asset: PHAsset, selectionOrder: Int?) {
        if asset.mediaType == .video {
            if selectionOrder == nil {
                self.setVideoDuration(asset.duration)
            } else {
                self.setVideoDuration(nil)
            }
        } else {
            self.setVideoDuration(nil)
        }
    }
}
