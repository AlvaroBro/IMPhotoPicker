//
//  CustomPickerWrapperViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 19/2/25.
//

import UIKit
import Photos

// MARK: - CustomPickerWrapperViewControllerDelegate
@objc public protocol CustomPickerWrapperViewControllerDelegate: IMPickerViewControllerDelegate {
    /// Called when the action button is tapped.
    func pickerWrapperViewController(_ controller: CustomPickerWrapperViewController, didTapActionButtonWithSelection selection: [PHAsset], hdModeEnabled: Bool)
}

// MARK: - CustomPickerWrapperViewController
@objcMembers public class CustomPickerWrapperViewController: UIViewController {
    
    // MARK: - Public Properties
    /// The configuration for the picker.
    public var configuration: IMPickerConfiguration = IMPickerConfiguration() {
        didSet {
            pickerViewController.configuration = configuration
        }
    }
    
    /// Delegate for container events.
    weak var delegate: CustomPickerWrapperViewControllerDelegate?
    
    /// The internally instantiated picker.
    let pickerViewController: IMPickerViewController
    let customBottomBar = CustomBottomBarView()

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
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChildNavigationController()
        setupBottomBar()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if pickerViewController.contentInsetTop == 0 && view.safeAreaInsets.top > 0 {
            pickerViewController.contentInsetTop = view.safeAreaInsets.top
        }
        
        if !customBottomBar.isHidden {
            pickerViewController.contentInsetBottom = customBottomBar.frame.height
        } else {
            pickerViewController.contentInsetBottom = view.safeAreaInsets.bottom
        }
    }
    
    // MARK: - Setup Methods
    
    /// Sets up the custom bottom bar with the action button.
    private func setupBottomBar() {
        customBottomBar.isHidden = true
        view.addSubview(customBottomBar)
        
        NSLayoutConstraint.activate([
            customBottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customBottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customBottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        customBottomBar.actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    /// Sets up the child navigation controller that embeds the picker view controller.
    private func setupChildNavigationController() {
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
    }
    
    // MARK: - Action Methods
    /// Called when the custom action button is tapped.
    @objc private func actionButtonTapped() {
        delegate?.pickerWrapperViewController(self,
            didTapActionButtonWithSelection: pickerViewController.assets,
            hdModeEnabled: pickerViewController.isHDModeEnabled)
    }
    
    // MARK: - Public Methods
    /// Updates the bottom bar visibility based on the number of selected assets.
    public func updateInputBarVisibility(selectedAssetCount: Int) {
        self.selectedAssetCount = selectedAssetCount
        let shouldShowBar = (selectedAssetCount > 0)
        customBottomBar.isHidden = !shouldShowBar
        
        if shouldShowBar {
            pickerViewController.contentInsetBottom = customBottomBar.frame.height
        } else {
            pickerViewController.contentInsetBottom = view.safeAreaInsets.bottom
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - IMPickerViewControllerDelegate
extension CustomPickerWrapperViewController: IMPickerViewControllerDelegate {

    public func pickerViewController(_ controller: IMPickerViewController, didUpdateSelection selection: [PHAsset], hdModeEnabled: Bool) {
        delegate?.pickerViewController(controller, didUpdateSelection: selection, hdModeEnabled: hdModeEnabled)
        updateInputBarVisibility(selectedAssetCount: selection.count)
    }

    public func pickerViewController(_ controller: IMPickerViewController, didFinishPicking selection: [PHAsset], hdModeEnabled: Bool) {
        delegate?.pickerViewController(controller, didFinishPicking: selection, hdModeEnabled: hdModeEnabled)
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
extension CustomPickerWrapperViewController: UISheetPresentationControllerDelegate {
    public func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate Implementation
extension CustomPickerWrapperViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        delegate?.pickerViewControllerDidAttemptToDismiss(pickerViewController)
    }
}
