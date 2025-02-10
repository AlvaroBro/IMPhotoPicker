//
//  CustomPickerContainerViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 9/2/25.
//

import UIKit
import Photos

// MARK: - CustomPickerContainerViewControllerDelegate
public protocol CustomPickerContainerViewControllerDelegate: CustomPickerViewControllerDelegate {
    /// Called when the send button is tapped.
    func customPickerContainerViewController(_ controller: CustomPickerContainerViewController, didTapSendWithText text: String)
}

// MARK: - CustomPickerContainerViewController
public class CustomPickerContainerViewController: UIViewController {

    // MARK: - Public Properties
    /// Delegate for container events.
    public weak var containerDelegate: CustomPickerContainerViewControllerDelegate?
    
    /// The internally instantiated picker.
    public let pickerViewController: CustomPickerViewController
    
    /// The input bar view.
    public let inputBar: InputBarView

    // MARK: - Private Properties
    private let childNavigationController: UINavigationController
    private let keyboardFrameTrackerView = KeyboardFrameTrackerView(height: 56)
    private var inputBarBottomConstraint: NSLayoutConstraint!
    private var inputBarHeightConstraint: NSLayoutConstraint!
    private var childNavigationControllerBottomConstraint: NSLayoutConstraint!
    private var visibleKeyboardHeight: CGFloat = 0
    private var selectedAssetCount: Int = 0

    // MARK: - Initializers
    public init() {
        pickerViewController = CustomPickerViewController()
        pickerViewController.rightButtonStyle = .hdModeToggle
        childNavigationController = UINavigationController(rootViewController: pickerViewController)
        inputBar = InputBarView()
        super.init(nibName: nil, bundle: nil)
        pickerViewController.delegate = self
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
        
        childNavigationControllerBottomConstraint = childNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            childNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
            childNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childNavigationControllerBottomConstraint
        ])
        
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputBar)
        
        inputBarBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        inputBarHeightConstraint = inputBar.heightAnchor.constraint(equalToConstant: 56)
        
        NSLayoutConstraint.activate([
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBarBottomConstraint,
            inputBarHeightConstraint
        ])
        
        inputBar.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        keyboardFrameTrackerView.delegate = self
    }

    // MARK: - Public Methods
    /// Updates the input bar visibility based on the number of selected assets.
    public func updateInputBarVisibility(selectedAssetCount: Int) {
        self.selectedAssetCount = selectedAssetCount
        UIView.animate(withDuration: 0.3, animations: {
            if selectedAssetCount == 0 {
                self.inputBar.textField.resignFirstResponder()
            }
            self.updateFrames(selectedAssetCount: selectedAssetCount)
        })
    }

    public override var canBecomeFirstResponder: Bool {
        true
    }
    
    public override var inputAccessoryView: UIView? {
        keyboardFrameTrackerView
    }

    // MARK: - Private Methods
    @objc private func sendButtonTapped() {
        containerDelegate?.customPickerContainerViewController(self, didTapSendWithText: inputBar.textField.text ?? "")
    }
    
    private func updateFrames(selectedAssetCount: Int) {
        let bottomSafeArea = view.safeAreaInsets.bottom
        let bottomGap = max(bottomSafeArea - visibleKeyboardHeight, 0)
        
        if visibleKeyboardHeight > 0 {
            inputBarHeightConstraint.constant = 56 + bottomGap
            inputBarBottomConstraint.constant = min(-visibleKeyboardHeight, -bottomSafeArea) + bottomGap
        } else {
            inputBarHeightConstraint.constant = 56 + bottomSafeArea
            inputBarBottomConstraint.constant = selectedAssetCount != 0 ? 0 : inputBarHeightConstraint.constant
        }
        
        childNavigationControllerBottomConstraint.constant = -visibleKeyboardHeight - (selectedAssetCount == 0 ? 0 : inputBarHeightConstraint.constant)
        
        view.layoutIfNeeded()
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
}

// MARK: - CustomPickerViewControllerDelegate
extension CustomPickerContainerViewController: CustomPickerViewControllerDelegate {

    public func customPickerViewController(
        _ controller: CustomPickerViewController,
        didUpdateSelection selection: [PHAsset],
        hdModeEnabled: Bool
    ) {
        self.inputBar.badgeCount = selection.count
        containerDelegate?.customPickerViewController(controller,
            didUpdateSelection: selection,
            hdModeEnabled: hdModeEnabled
        )
    }

    public func customPickerViewController(
        _ controller: CustomPickerViewController,
        didFinishPicking selection: [PHAsset],
        hdModeEnabled: Bool
    ) {
        containerDelegate?.customPickerViewController(controller,
            didFinishPicking: selection,
            hdModeEnabled: hdModeEnabled
        )
    }

    public func customPickerViewControllerDidCancel(_ controller: CustomPickerViewController) {
        containerDelegate?.customPickerViewControllerDidCancel(controller)
    }

    public func customPickerViewControllerDidTapRightButton(_ controller: CustomPickerViewController) {
        containerDelegate?.customPickerViewControllerDidTapRightButton(controller)
    }
}

// MARK: - KeyboardFrameTrackerDelegate
extension CustomPickerContainerViewController: KeyboardFrameTrackerDelegate {
    public func keyboardFrameDidChange(with frame: CGRect) {
        let screenHeight = UIScreen.main.bounds.height
        visibleKeyboardHeight = max(0, screenHeight - frame.origin.y - keyboardFrameTrackerView.frame.size.height)
        if visibleKeyboardHeight > 0 {
            switchToLargeDetentIfNeeded()
        }
        updateFrames(selectedAssetCount: selectedAssetCount)
    }
}
