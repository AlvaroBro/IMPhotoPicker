//
//  IMLimitedAccessBannerView.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 14/1/26.
//

import UIKit

/// A banner view that informs the user about limited photo library access
/// and provides a tappable "Manage" link within the text to modify permissions.
@objcMembers public class IMLimitedAccessBannerView: UIView {
    
    // MARK: - Public Properties
    
    /// Called when the user taps the "Manage" link.
    var onManageTapped: (() -> Void)?
    
    /// The text color for the message.
    var messageTextColor: UIColor = .secondaryLabel {
        didSet {
            updateAttributedText()
        }
    }
    
    /// The text color for the manage link.
    var manageLinkColor: UIColor = .systemBlue {
        didSet {
            updateAttributedText()
        }
    }
    
    /// The font for the banner text.
    var textFont: UIFont = .systemFont(ofSize: 14) {
        didSet {
            updateAttributedText()
        }
    }
    
    // MARK: - Private Properties
    
    private var messageText: String = NSLocalizedString("limited_access_message", tableName: "IMPhotoPicker", comment: "")
    private var manageLinkText: String = NSLocalizedString("limited_access_manage_button", tableName: "IMPhotoPicker", comment: "")
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .secondarySystemBackground
        
        addSubview(textLabel)
        
        // Center horizontally with a max width, more vertical padding
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        textLabel.addGestureRecognizer(tapGesture)
        
        updateAttributedText()
    }
    
    // MARK: - Attributed Text
    
    private func updateAttributedText() {
        let fullText = "\(messageText) \(manageLinkText)"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Create a semibold version of the font for the link
        let linkFont: UIFont
        if let fontDescriptor = textFont.fontDescriptor.withSymbolicTraits(.traitBold) {
            linkFont = UIFont(descriptor: fontDescriptor, size: textFont.pointSize)
        } else {
            linkFont = UIFont.systemFont(ofSize: textFont.pointSize, weight: .semibold)
        }
        
        // Style for the message part
        let messageRange = NSRange(location: 0, length: messageText.count)
        attributedString.addAttributes([
            .foregroundColor: messageTextColor,
            .font: textFont
        ], range: messageRange)
        
        // Style for the manage link part
        let linkRange = NSRange(location: messageText.count + 1, length: manageLinkText.count)
        attributedString.addAttributes([
            .foregroundColor: manageLinkColor,
            .font: linkFont
        ], range: linkRange)
        
        textLabel.attributedText = attributedString
    }
    
    // MARK: - Tap Handling
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let attributedText = textLabel.attributedText else { return }
        
        let linkRange = NSRange(location: messageText.count + 1, length: manageLinkText.count)
        
        // Create a text container and layout manager to calculate tap position
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: textLabel.bounds.width, height: .greatestFiniteMagnitude))
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = textLabel.lineBreakMode
        textContainer.maximumNumberOfLines = textLabel.numberOfLines
        
        let tapLocation = gesture.location(in: textLabel)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        // Adjust for text alignment
        let textContainerOffset = CGPoint(
            x: (textLabel.bounds.width - textBoundingBox.width) / 2 - textBoundingBox.origin.x,
            y: (textLabel.bounds.height - textBoundingBox.height) / 2 - textBoundingBox.origin.y
        )
        
        let locationOfTouchInTextContainer = CGPoint(
            x: tapLocation.x - textContainerOffset.x,
            y: tapLocation.y - textContainerOffset.y
        )
        
        let indexOfCharacter = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // Check if tap is within the link range
        if NSLocationInRange(indexOfCharacter, linkRange) {
            onManageTapped?()
        }
    }
    
    // MARK: - Public Methods
    
    /// Updates the message text (without the link part).
    func setMessage(_ message: String) {
        messageText = message
        updateAttributedText()
    }
    
    /// Updates the manage link text.
    func setManageButtonTitle(_ title: String) {
        manageLinkText = title
        updateAttributedText()
    }
}
