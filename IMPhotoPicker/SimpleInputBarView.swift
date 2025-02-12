//
//  SimpleInputBarView.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 12/2/25.
//

import UIKit

// MARK: - SimpleInputBarView
public class SimpleInputBarView: UIView {

    public let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.layer.cornerRadius = 8
        tv.layer.borderWidth = 1.0
        tv.layer.borderColor = UIColor.lightGray.cgColor
        return tv
    }()
    
    public let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        return button
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    public override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    public override var isFirstResponder: Bool {
        return textView.isFirstResponder
    }
    
    public override var intrinsicContentSize: CGSize {
        let bottomInset = safeAreaInsets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: 44 + bottomInset)
    }
    
    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = .secondarySystemBackground
        addSubview(textView)
        addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
}
