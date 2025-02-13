//
//  IMAlbumCell.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit

// MARK: - IMAlbumCell
class IMAlbumCell: UITableViewCell {
    
    static let identifier = "IMAlbumCell"
    
    // MARK: - Initializers
    
    let albumImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let disclosureImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = .lightGray.withAlphaComponent(0.5)
        return iv
    }()
    
    private let topSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        return view
    }()
    
    private let bottomSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        
        contentView.addSubview(cardView)
        cardView.addSubview(albumImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(disclosureImageView)
        cardView.addSubview(topSeparator)
        cardView.addSubview(bottomSeparator)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            albumImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            albumImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            albumImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            albumImageView.widthAnchor.constraint(equalToConstant: 60),
            albumImageView.heightAnchor.constraint(equalToConstant: 60),
            
            disclosureImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            disclosureImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: disclosureImageView.leadingAnchor, constant: -10),
            
            topSeparator.topAnchor.constraint(equalTo: cardView.topAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 0.25),
            
            bottomSeparator.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            bottomSeparator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 0.25)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumImageView.image = nil
        titleLabel.text = nil
    }
    
    // MARK: - Public Methods
    
    public func updateAppearance(isFirst: Bool, isLast: Bool) {
        topSeparator.isHidden = isFirst
        bottomSeparator.isHidden = isLast
        
        var maskedCorners: CACornerMask = []
        if isFirst {
            maskedCorners.insert(.layerMinXMinYCorner)
            maskedCorners.insert(.layerMaxXMinYCorner)
        }
        if isLast {
            maskedCorners.insert(.layerMinXMaxYCorner)
            maskedCorners.insert(.layerMaxXMaxYCorner)
        }
        if !maskedCorners.isEmpty {
            cardView.layer.cornerRadius = 8
            cardView.layer.maskedCorners = maskedCorners
        } else {
            cardView.layer.cornerRadius = 0
        }
    }
}
