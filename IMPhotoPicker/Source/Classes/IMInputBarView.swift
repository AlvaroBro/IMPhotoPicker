//
//  IMInputBarView.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 9/2/25.
//

import UIKit

// MARK: - IMInputBarView
@objcMembers public class IMInputBarView: UIView, UITextViewDelegate {

    // MARK: - Public Properties
    /// The text view for input.
    public let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .white
        tv.layer.borderColor = UIColor.gray.cgColor
        tv.layer.borderWidth = 1.0
        tv.layer.cornerRadius = 10.0
        tv.clipsToBounds = true
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        return tv
    }()

    /// The send button with a paper plane icon.
    public let sendButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        if let sendImage = UIImage(systemName: "paperplane.fill") {
            btn.setImage(sendImage, for: .normal)
        }
        btn.tintColor = .white
        btn.backgroundColor = .systemBlue
        btn.clipsToBounds = false
        return btn
    }()

    /// The badge count indicating the number of selected items.
    public var badgeCount: Int = 0 {
        didSet {
            badgeLabel.text = "\(badgeCount)"
            badgeLabel.isHidden = badgeCount <= 0
        }
    }

    // MARK: - Private Properties
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemBlue
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.isHidden = true
        label.layer.borderWidth = 1.5
        label.layer.borderColor = UIColor.white.cgColor
        return label
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private var textViewHeightConstraint: NSLayoutConstraint!
    private let maxNumberOfLines: CGFloat = 5

    // MARK: - Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Public Methods
    public override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    public override var isFirstResponder: Bool {
        return textView.isFirstResponder
    }

    public override var intrinsicContentSize: CGSize {
        let bottomInset = safeAreaInsets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: 56 + bottomInset)
    }

    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        invalidateIntrinsicContentSize()
    }

    public func applyConfiguration(_ config: IMInputBarConfiguration?) {
        placeholderLabel.text = config?.placeholder ?? NSLocalizedString("input_placeholder", tableName: "IMPhotoPicker", comment: "")
        placeholderLabel.font = config?.textFieldFont ?? UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = config?.textFieldBackgroundColor ?? .white
        textView.font = config?.textFieldFont ?? UIFont.systemFont(ofSize: 14)
        sendButton.setImage(config?.sendButtonImage ?? UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = config?.sendButtonTintColor ?? .white
        sendButton.backgroundColor = config?.sendButtonBackgroundColor ?? .systemBlue
        badgeLabel.backgroundColor = config?.sendButtonBadgeColor ?? .systemBlue
        textViewDidChange(textView)
    }

    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = .secondarySystemBackground
        addSubview(textView)
        addSubview(sendButton)
        sendButton.addSubview(badgeLabel)

        textView.delegate = self
        textView.addSubview(placeholderLabel)

        let initialHeight = (textView.font?.lineHeight ?? 17) + textView.textContainerInset.top + textView.textContainerInset.bottom
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: initialHeight)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 12),
            textView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            textViewHeightConstraint,

            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 12),
            sendButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -12),
            sendButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0),
            sendButton.heightAnchor.constraint(equalToConstant: 34),
            sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor),

            badgeLabel.topAnchor.constraint(equalTo: sendButton.topAnchor, constant: -6),
            badgeLabel.trailingAnchor.constraint(equalTo: sendButton.trailingAnchor, constant: 6),
            badgeLabel.widthAnchor.constraint(equalToConstant: 20),
            badgeLabel.heightAnchor.constraint(equalToConstant: 20),

            placeholderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: textView.textContainerInset.left + textView.textContainer.lineFragmentPadding)
        ])

        sendButton.layer.cornerRadius = 18
        badgeLabel.layer.cornerRadius = 10
    }

    // MARK: - UITextViewDelegate
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty

        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let maxHeight = (textView.font?.lineHeight ?? 17) * maxNumberOfLines + textView.textContainerInset.top + textView.textContainerInset.bottom

        if size.height <= maxHeight {
            textViewHeightConstraint.constant = size.height
            textView.isScrollEnabled = false
        } else {
            textViewHeightConstraint.constant = maxHeight
            textView.isScrollEnabled = true
        }
        layoutIfNeeded()
    }
}
