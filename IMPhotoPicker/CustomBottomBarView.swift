//
//  CustomBottomBarView.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 19/2/25.
//

import UIKit

/// A custom bottom bar view that contains an action button.
@objcMembers public class CustomBottomBarView: UIView {

    /// The action button displayed in the bottom bar.
    public let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Custom Action", for: .normal)
        return button
    }()

    private let topMargin: CGFloat = 10
    private let bottomMargin: CGFloat = 10

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .secondarySystemBackground
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: topAnchor, constant: topMargin)
        ])
    }

    // MARK: - Intrinsic Content Size

    public override var intrinsicContentSize: CGSize {
        let buttonHeight = actionButton.intrinsicContentSize.height
        let safeBottom = safeAreaInsets.bottom
        let height = topMargin + buttonHeight + bottomMargin + safeBottom
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        invalidateIntrinsicContentSize()
    }
}
