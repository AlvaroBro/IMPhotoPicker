//
//  IMPhotoCell.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit
import Photos

// MARK: - IMPhotoCell
class IMPhotoCell: UICollectionViewCell {
    static let reuseIdentifier = "IMPhotoCell"
    
    // MARK: - UI Properties
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
        label.layer.borderWidth = 2
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
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
