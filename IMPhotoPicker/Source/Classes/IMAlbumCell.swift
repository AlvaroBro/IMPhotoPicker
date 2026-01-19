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
        contentView.backgroundColor = .clear
        
        albumImageView.translatesAutoresizingMaskIntoConstraints = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = true
        cardView.translatesAutoresizingMaskIntoConstraints = true
        disclosureImageView.translatesAutoresizingMaskIntoConstraints = true
        topSeparator.translatesAutoresizingMaskIntoConstraints = true
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = true

        contentView.addSubview(cardView)
        cardView.addSubview(albumImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(disclosureImageView)
        cardView.addSubview(topSeparator)
        cardView.addSubview(bottomSeparator)
        
        cardView.autoresizingMask = [.flexibleWidth]
        albumImageView.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
        disclosureImageView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
        topSeparator.autoresizingMask = [.flexibleWidth]
        bottomSeparator.autoresizingMask = [.flexibleWidth]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = contentView.bounds
        
        cardView.frame = CGRect(x: 16, y: 0, width: bounds.width - 32, height: bounds.height)
        
        let cardBounds = cardView.bounds
        
        albumImageView.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        
        let disclosureWidth: CGFloat = 16
        disclosureImageView.frame = CGRect(x: cardBounds.width - disclosureWidth - 10,
                                           y: (cardBounds.height - disclosureWidth) / 2,
                                           width: disclosureWidth,
                                           height: disclosureWidth)
        
        let titleX = albumImageView.frame.maxX + 10
        let titleWidth = disclosureImageView.frame.minX - titleX - 10
        titleLabel.frame = CGRect(x: titleX,
                                  y: 0,
                                  width: titleWidth,
                                  height: cardBounds.height)
                                  
        topSeparator.frame = CGRect(x: titleX, y: 0, width: cardBounds.width - titleX, height: 0.25)
        bottomSeparator.frame = CGRect(x: titleX, y: cardBounds.height - 0.25, width: cardBounds.width - titleX, height: 0.25)
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
