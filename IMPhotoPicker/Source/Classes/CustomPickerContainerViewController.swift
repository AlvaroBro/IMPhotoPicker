//
//  CustomPickerContainerViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 9/2/25.
//

import UIKit

// MARK: - CustomPickerContainerViewControllerDelegate
/// Delegate protocol for container events.
public protocol CustomPickerContainerViewControllerDelegate: AnyObject {
    /// Called when the send button is tapped.
    func customPickerContainerViewController(_ controller: CustomPickerContainerViewController, didTapSendWithText text: String)
}

// MARK: - CustomPickerContainerViewController
public class CustomPickerContainerViewController: UIViewController {

    // MARK: - Public Properties

    /// Delegate for the embedded picker.
    public weak var pickerDelegate: CustomPickerViewControllerDelegate? {
        didSet {
            pickerViewController.delegate = pickerDelegate
        }
    }
    
    /// Delegate for container events.
    public weak var containerDelegate: CustomPickerContainerViewControllerDelegate?
    
    /// The internally instantiated picker.
    public let pickerViewController: CustomPickerViewController
    
    /// The input bar view.
    public let inputBar: InputBarView

    // MARK: - Private Properties

    private let childNavigationController: UINavigationController
    private var inputBarHeightConstraint: NSLayoutConstraint!
    private var inputBarBottomConstraint: NSLayoutConstraint!
    private var keyboardVisible = false

    // MARK: - Initializers

    /// Initializes the container with the specified right button style.
    public init(rightButtonStyle: CustomPickerViewController.CustomPickerRightButtonStyle) {
        pickerViewController = CustomPickerViewController()
        pickerViewController.rightButtonStyle = rightButtonStyle
        childNavigationController = UINavigationController(rootViewController: pickerViewController)
        inputBar = InputBarView()
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        addChild(childNavigationController)
        childNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childNavigationController.view)
        childNavigationController.didMove(toParent: self)
        NSLayoutConstraint.activate([
            childNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
            childNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputBar)
        inputBarBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        inputBarHeightConstraint = inputBar.heightAnchor.constraint(equalToConstant: 56 + view.safeAreaInsets.bottom)
        NSLayoutConstraint.activate([
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBarBottomConstraint,
            inputBarHeightConstraint
        ])
        inputBar.backgroundColor = .secondarySystemBackground
        inputBar.isHidden = true
        view.bringSubviewToFront(inputBar)
        inputBar.transform = CGAffineTransform(translationX: 0, y: inputBarHeightConstraint.constant)
        inputBar.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let desiredHeight: CGFloat = keyboardVisible ? 56 : (56 + view.safeAreaInsets.bottom)
        inputBarHeightConstraint.constant = desiredHeight
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public Methods

    /// Shows the input bar.
    public func showInputBar() {
        guard inputBar.isHidden else { return }
        inputBar.isHidden = false
        inputBar.transform = CGAffineTransform(translationX: 0, y: inputBarHeightConstraint.constant)
        UIView.animate(withDuration: 0.3) {
            self.inputBar.transform = .identity
        }
    }

    /// Hides the input bar.
    public func hideInputBar() {
        guard !inputBar.isHidden else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.inputBar.transform = CGAffineTransform(translationX: 0, y: self.inputBarHeightConstraint.constant)
        }) { _ in
            self.inputBar.isHidden = true
        }
    }

    /// Updates the input bar visibility based on the number of selected assets.
    public func updateInputBarVisibility(selectedAssetCount: Int) {
        if selectedAssetCount > 0 {
            showInputBar()
        } else {
            hideInputBar()
            self.inputBar.textField.resignFirstResponder()
        }
    }

    // MARK: - Private Methods

    @objc private func sendButtonTapped() {
        containerDelegate?.customPickerContainerViewController(self, didTapSendWithText: inputBar.textField.text ?? "")
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        keyboardVisible = true
        inputBarHeightConstraint.constant = 56
        inputBarBottomConstraint.constant = -keyboardFrame.height
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        keyboardVisible = false
        inputBarHeightConstraint.constant = 56 + view.safeAreaInsets.bottom
        inputBarBottomConstraint.constant = 0
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}
