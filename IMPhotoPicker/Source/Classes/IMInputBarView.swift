//
//  IMInputBarView.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 9/2/25.
//

import UIKit

// MARK: - IMInputBarView
public class IMInputBarView: UIView {

    // MARK: - Public Properties
    /// The text field for input.
    public let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = NSLocalizedString("input_placeholder", comment: "")
        tf.backgroundColor = .white
        tf.borderStyle = .none
        tf.layer.borderColor = UIColor.gray.cgColor
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 10.0
        tf.clipsToBounds = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    
    /// The send button with a paper plane icon.
    public let sendButton: UIButton = {
        let btn = UIButton(type: .system)
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
        return textField.resignFirstResponder()
    }
    
    public override var isFirstResponder: Bool {
        return textField.isFirstResponder
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
        textField.placeholder = config?.placeholder
        textField.backgroundColor = config?.textFieldBackgroundColor
        textField.font = config?.textFieldFont
        sendButton.setImage(config?.sendButtonImage, for: .normal)
        sendButton.tintColor = config?.sendButtonTintColor
        sendButton.backgroundColor = config?.sendButtonBackgroundColor
        badgeLabel.backgroundColor = config?.sendButtonBadgeColor
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = .secondarySystemBackground
        addSubview(textField)
        addSubview(sendButton)
        sendButton.addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            textField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            
            sendButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 36),
            sendButton.heightAnchor.constraint(equalToConstant: 36),
            sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor),
            
            badgeLabel.topAnchor.constraint(equalTo: sendButton.topAnchor, constant: -6),
            badgeLabel.trailingAnchor.constraint(equalTo: sendButton.trailingAnchor, constant: 6),
            badgeLabel.widthAnchor.constraint(equalToConstant: 20),
            badgeLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        sendButton.layer.cornerRadius = 18
        badgeLabel.layer.cornerRadius = 10
    }
}
