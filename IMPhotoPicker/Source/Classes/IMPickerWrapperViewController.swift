//
//  IMPickerWrapperViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 9/2/25.
//

import UIKit
import Photos

// MARK: - IMPickerWrapperViewControllerDelegate
public protocol IMPickerWrapperViewControllerDelegate: IMPickerViewControllerDelegate {
    /// Called when the send button is tapped.
    func pickerWrapperViewController(_ controller: IMPickerWrapperViewController, didTapSendWithText text: String)
}

// MARK: - IMPickerWrapperViewController
public class IMPickerWrapperViewController: UIViewController {

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
    private var childNavigationControllerBottomConstraint: NSLayoutConstraint!
    private var selectedAssetCount: Int = 0

    // MARK: - Initializers
    public init() {
        pickerViewController = IMPickerViewController()
        pickerViewController.configuration = IMPickerConfiguration(rightButtonStyle: .hdModeToggle)
        pickerViewController.adjustsContentInset = false
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
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !pickerViewController.adjustsContentInset {
            if pickerViewController.keyboardInset == 0 && view.safeAreaInsets.bottom > 0{
                pickerViewController.keyboardInset = view.safeAreaInsets.bottom
            }
        }
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
        
        childNavigationControllerBottomConstraint = childNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            childNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
            childNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childNavigationControllerBottomConstraint
        ])
        
        inputBar.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }

    // MARK: - Public Methods
    /// Updates the input bar visibility based on the number of selected assets.
    public func updateInputBarVisibility(selectedAssetCount: Int) {
        self.selectedAssetCount = selectedAssetCount
        if selectedAssetCount > 0 {
            if !inputBar.isFirstResponder, !isFirstResponder {
                becomeFirstResponder()
            }
        } else {
            if isFirstResponder {
                resignFirstResponder()
            } else if inputBar.isFirstResponder {
                _ = inputBar.resignFirstResponder()
            }
        }
    }
    
    public override var inputAccessoryView: UIView? {
        return self.selectedAssetCount > 0 ? inputBar : nil
    }
    
    public override var canBecomeFirstResponder: Bool {
        return self.selectedAssetCount > 0
    }

    // MARK: - Private Methods
    @objc private func sendButtonTapped() {
        delegate?.pickerWrapperViewController(self, didTapSendWithText: inputBar.textField.text ?? "")
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
    
    // MARK: - Keyboard notifications

    @objc func keyboardWillChangeFrame(notification: Notification) {
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
            self.pickerViewController.keyboardInset = bottomInset
        }, completion: nil)
    }

    @objc func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: curveValue << 16),
                       animations: {
            self.pickerViewController.keyboardInset = self.view.safeAreaInsets.bottom
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
}
