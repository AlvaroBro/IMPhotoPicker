//
//  IMPickerWrapperViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 9/2/25.
//

import UIKit
import Photos

// MARK: - IMPickerWrapperViewControllerDelegate
@objc public protocol IMPickerWrapperViewControllerDelegate: IMPickerViewControllerDelegate {
    /// Called when the send button is tapped.
    func pickerWrapperViewController(_ controller: IMPickerWrapperViewController, didTapSendWithText text: String, selection: [PHAsset], hdModeEnabled: Bool)
}

// MARK: - IMPickerWrapperViewController
@objcMembers public class IMPickerWrapperViewController: UIViewController {

    // MARK: - Public Properties
    ///
    public var configuration: IMPickerConfiguration = IMPickerConfiguration() {
        didSet {
            pickerViewController.configuration = configuration
            inputBar.applyConfiguration(configuration.inputBarConfiguration)
        }
    }
    
    /// Delegate for container events.
    public weak var delegate: IMPickerWrapperViewControllerDelegate?
    
    /// The internally instantiated picker.
    public let pickerViewController: IMPickerViewController
    
    /// The input bar view.
    public let inputBar: IMInputBarView = {
        let view = IMInputBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Private Properties
    private let childNavigationController: UINavigationController
    private var selectedAssetCount: Int = 0

    // MARK: - Initializers
    public init() {
        pickerViewController = IMPickerViewController()
        pickerViewController.configuration = IMPickerConfiguration()
        pickerViewController.configuration.rightButtonStyle = .hdModeToggle
        childNavigationController = UINavigationController(rootViewController: pickerViewController)
        super.init(nibName: nil, bundle: nil)
        pickerViewController.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        inputBar.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if pickerViewController.contentInsetBottom == 0 && view.safeAreaInsets.bottom > 0 {
            pickerViewController.contentInsetBottom = view.safeAreaInsets.bottom
        }
    }

    // MARK: - Public Methods
    public override var inputAccessoryView: UIView? {
        return selectedAssetCount > 0 ? inputBar : nil
    }
    
    public override var canBecomeFirstResponder: Bool {
        return selectedAssetCount > 0
    }
    
    public override func resignFirstResponder() -> Bool {
        if isFirstResponder {
            return super.resignFirstResponder()
        } else if inputBar.isFirstResponder {
            return inputBar.resignFirstResponder()
        }
        return false
    }

    // MARK: - Private Methods
    private func updateInputBarVisibility(selectedAssetCount: Int) {
        self.selectedAssetCount = selectedAssetCount
        if selectedAssetCount > 0 {
            if !inputBar.isFirstResponder, !isFirstResponder {
                becomeFirstResponder()
            }
        } else {
            _ = resignFirstResponder()
        }
    }
    
    @objc private func sendButtonTapped() {
        delegate?.pickerWrapperViewController(self, didTapSendWithText: inputBar.textView.text ?? "", selection: pickerViewController.assets, hdModeEnabled: pickerViewController.isHDModeEnabled)
    }
    
    private func switchToLargeDetentIfNeeded() {
        if #available(iOS 15.0, *) {
            if let sheet = sheetPresentationController {
                sheet.animateChanges {
                    sheet.selectedDetentIdentifier = .large
                }
            }
        }
    }
    
    private func hideKeyboardAccountingForBarVisibility() {
        if selectedAssetCount > 0 {
            if inputBar.isFirstResponder {
                becomeFirstResponder()
            }
        } else {
            _ = resignFirstResponder()
        }
    }
    
    // MARK: - Keyboard notifications

    func keyboardWillChangeFrame(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let convertedFrame = view.convert(keyboardFrame, from: nil)
        let intersection = view.bounds.intersection(convertedFrame)
        let bottomInset = intersection.height
        let keyboardWillAppear = bottomInset - inputBar.frame.size.height > 0
        
        if keyboardWillAppear {
            switchToLargeDetentIfNeeded()
        }
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: curveValue << 16),
                       animations: {
            self.pickerViewController.contentInsetBottom = bottomInset
        }, completion: nil)
    }

    func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: curveValue << 16),
                       animations: {
            self.pickerViewController.contentInsetBottom = self.view.safeAreaInsets.bottom
        }, completion: nil)
    }
}

// MARK: - IMPickerViewControllerDelegate
extension IMPickerWrapperViewController: IMPickerViewControllerDelegate {

    public func pickerViewController(_ controller: IMPickerViewController, didUpdateSelection selection: [PHAsset], hdModeEnabled: Bool) {
        self.inputBar.badgeCount = selection.count
        delegate?.pickerViewController(controller,
            didUpdateSelection: selection,
            hdModeEnabled: hdModeEnabled
        )
        updateInputBarVisibility(selectedAssetCount: selection.count)
    }

    public func pickerViewController(_ controller: IMPickerViewController, didFinishPicking selection: [PHAsset], hdModeEnabled: Bool) {
        delegate?.pickerViewController(controller,
            didFinishPicking: selection,
            hdModeEnabled: hdModeEnabled
        )
    }

    public func pickerViewControllerDidCancel(_ controller: IMPickerViewController) {
        delegate?.pickerViewControllerDidCancel(controller)
    }

    public func pickerViewControllerDidTapRightButton(_ controller: IMPickerViewController) {
        delegate?.pickerViewControllerDidTapRightButton(controller)
    }
    
    public func pickerViewController(_ controller: IMPickerViewController, didFailWithPermissionError error: Error) {
        delegate?.pickerViewController(controller, didFailWithPermissionError: error)
    }
    
    public func pickerViewControllerDidAttemptToDismiss(_ controller: IMPickerViewController) {
        delegate?.pickerViewControllerDidAttemptToDismiss(controller)
    }
}

// MARK: - UISheetPresentationControllerDelegate Implementation
@available(iOS 15.0, *)
extension IMPickerWrapperViewController: UISheetPresentationControllerDelegate {
    public func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        if let detent = sheetPresentationController.selectedDetentIdentifier {
            if detent.rawValue == "custom.detent" {
                hideKeyboardAccountingForBarVisibility()
            }
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate Implementation
extension IMPickerWrapperViewController : UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        delegate?.pickerViewControllerDidAttemptToDismiss(pickerViewController)
    }
}
