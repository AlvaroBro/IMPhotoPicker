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
    
    // Public image view for album thumbnail
    let albumImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    // Public label for album title
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        contentView.addSubview(albumImageView)
        contentView.addSubview(titleLabel)
        
        let margin: CGFloat = 10
        let imageSize: CGFloat = 60
        
        NSLayoutConstraint.activate([
            albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            albumImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin),
            albumImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin),
            albumImageView.widthAnchor.constraint(equalToConstant: imageSize),
            albumImageView.heightAnchor.constraint(equalToConstant: imageSize),
            
            titleLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: margin),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let margin: CGFloat = 10
        separatorInset = UIEdgeInsets(top: 0, left: albumImageView.frame.maxX + margin, bottom: 0, right: 0)
    }
}
