//
//  IMPickerViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit
import Photos

// MARK: - IMPickerViewControllerDelegate
/// Delegate protocol for IMPickerViewController events.
@objc public protocol IMPickerViewControllerDelegate: AnyObject {
    /// Called whenever the selection is updated.
    func pickerViewController(_ controller: IMPickerViewController, didUpdateSelection selection: [PHAsset], hdModeEnabled: Bool)
    
    /// Called when the user accepts the selection.
    func pickerViewController(_ controller: IMPickerViewController, didFinishPicking selection: [PHAsset], hdModeEnabled: Bool)
    
    /// Called when the user cancels the picker.
    func pickerViewControllerDidCancel(_ controller: IMPickerViewController)
    
    /// (Optional) Called when the right bar button is tapped.
    /// This allows the picker presenter to decide how to react.
    func pickerViewControllerDidTapRightButton(_ controller: IMPickerViewController)
    
    /// Called when a permission error occurs.
    func pickerViewController(_ controller: IMPickerViewController, didFailWithPermissionError error: Error)
    
    /// Called when the user attempts to dismiss the picker (e.g., via a swipe-down gesture)
    /// but dismissal is prevented because one or more assets are currently selected.
    func pickerViewControllerDidAttemptToDismiss(_ controller: IMPickerViewController)

}

extension IMPickerViewControllerDelegate {
    func pickerViewControllerDidTapRightButton(_ controller: IMPickerViewController) { }
    func pickerViewController(_ controller: IMPickerViewController, didFailWithPermissionError error: Error) { }
    func pickerViewControllerDidAttemptToDismiss(_ controller: IMPickerViewController) { }
}

@objcMembers public class IMPickerViewController: UIViewController {

    // MARK: - Types
    @objc public enum CustomPickerRightButtonStyle: Int {
        case accept
        case hdModeToggle
        case custom
    }

    // MARK: - Public Properties
    
    var isHDModeEnabled: Bool {
        return hdModeEnabled
    }

    var assets: [PHAsset] {
        return selectedAssets
    }
    
    var selectionLimit: Int {
        configuration.selectionLimit
    }
    
    var rightButtonStyle: CustomPickerRightButtonStyle {
        configuration.rightButtonStyle
    }
    
    var configuration: IMPickerConfiguration = IMPickerConfiguration()
    
    var contentInsetTop: CGFloat? {
        didSet {
            view?.setNeedsLayout()
            view?.layoutIfNeeded()
        }
    }
    
    var contentInsetBottom: CGFloat? {
        didSet {
            view?.setNeedsLayout()
            view?.layoutIfNeeded()
        }
    }
    
    weak var delegate: IMPickerViewControllerDelegate?
    
    // MARK: - Public Methods
    
    func pickerWrapperContainer() -> IMPickerWrapperViewController? {
        return self.navigationController?.parent as? IMPickerWrapperViewController
    }
    
    // MARK: - Private Properties
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: [
            NSLocalizedString("photos_segment_title", tableName: "IMPhotoPicker", comment: ""),
            NSLocalizedString("albums_segment_title", tableName: "IMPhotoPicker", comment: "")
        ])
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let containerView = UIView()
    private let photosViewController = IMPhotosViewController()
    private let albumsViewController = IMAlbumsViewController()
    private var albumAssetsViewController: IMAlbumAssetsViewController?
    private var hdModeEnabled: Bool = false
    private var selectedAssets: [PHAsset] = []
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        configureNavigationBarAppearance()
        setupContainerView()
        setupChildViewControllers()
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        photosViewController.contentInsetTop = (contentInsetTop != nil ? contentInsetTop : view.safeAreaInsets.top)!
        photosViewController.contentInsetBottom = (contentInsetBottom != nil ? contentInsetBottom : view.safeAreaInsets.bottom)!
        albumsViewController.contentInsetTop = (contentInsetTop != nil ? contentInsetTop : view.safeAreaInsets.top)!
        albumsViewController.contentInsetBottom = (contentInsetBottom != nil ? contentInsetBottom : view.safeAreaInsets.bottom)!
        albumAssetsViewController?.contentInsetTop = (contentInsetTop != nil ? contentInsetTop : view.safeAreaInsets.top)!
        albumAssetsViewController?.contentInsetBottom = (contentInsetBottom != nil ? contentInsetBottom : view.safeAreaInsets.bottom)!
        
        setPresentationControllerDelegate()
    }
    
    // MARK: - Navigation Bar Setup
    func setupNavigationBar() {
        segmentedControl.selectedSegmentTintColor = configuration.segmentedControlSelectedSegmentTintColor
        segmentedControl.backgroundColor = configuration.segmentedControlTintColor
        segmentedControl.setTitleTextAttributes(configuration.segmentedControlTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(configuration.segmentedControlSelectedTextAttributes, for: .selected)
        
        navigationItem.titleView = segmentedControl
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("cancel_button_title", tableName: "IMPhotoPicker", comment: ""),
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = configuration.cancelButtonNavigationItemTintColor
        
        switch rightButtonStyle {
        case .accept:
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("accept_button_title", tableName: "IMPhotoPicker", comment: ""),
                style: .done,
                target: self,
                action: #selector(acceptTapped)
            )
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = configuration.rightNavigationItemTintColor
        case .hdModeToggle:
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: hdModeImage(),
                style: .plain,
                target: self,
                action: #selector(toggleHDMode)
            )
            navigationItem.rightBarButtonItem?.tintColor = configuration.rightNavigationItemTintColor
        case .custom:
            if let customItem = configuration.customRightBarButtonItem {
                navigationItem.rightBarButtonItem = customItem
                customItem.tintColor = configuration.rightNavigationItemTintColor
            }
        }
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .regular)
        appearance.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.5)
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - Container View Setup
    func setupContainerView() {
        containerView.backgroundColor = .secondarySystemBackground
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Child View Controllers Setup
    func setupChildViewControllers() {
        photosViewController.badgeColor = configuration.selectionOverlayBadgeColor
        photosViewController.selectionDelegate = self
        photosViewController.pickerController = self
        
        albumsViewController.delegate = self
        albumsViewController.pickerController = self
        
        addChild(photosViewController)
        containerView.addSubview(photosViewController.view)
        photosViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photosViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            photosViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            photosViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            photosViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        photosViewController.didMove(toParent: self)
        
        addChild(albumsViewController)
        containerView.addSubview(albumsViewController.view)
        albumsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            albumsViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            albumsViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            albumsViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            albumsViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        albumsViewController.didMove(toParent: self)
        
        photosViewController.view.isHidden = false
        albumsViewController.view.isHidden = true
    }
    
    // MARK: - Navigation Bar Actions
    func cancelTapped() {
        delegate?.pickerViewControllerDidCancel(self)
        dismiss(animated: true, completion: nil)
    }
    
    func acceptTapped() {
        delegate?.pickerViewControllerDidTapRightButton(self)
        delegate?.pickerViewController(self, didFinishPicking: selectedAssets, hdModeEnabled: hdModeEnabled)
        dismiss(animated: true, completion: nil)
    }
    
    func toggleHDMode() {
        hdModeEnabled.toggle()
        navigationItem.rightBarButtonItem?.image = hdModeImage()
        delegate?.pickerViewControllerDidTapRightButton(self)
        delegate?.pickerViewController(self, didUpdateSelection: selectedAssets, hdModeEnabled: hdModeEnabled)
    }
    
    private func hdModeImage() -> UIImage? {
        let imageName = hdModeEnabled ? "im-hd-selected" : "im-hd"
        return UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal) ?? nil
    }
    
    // MARK: - Segmented Control Action
    func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            switchToPhotos()
        } else {
            switchToAlbums()
        }
    }
    
    func switchToPhotos() {
        photosViewController.view.isHidden = false
        albumsViewController.view.isHidden = true
    }
    
    func switchToAlbums() {
        photosViewController.view.isHidden = true
        albumsViewController.view.isHidden = false
    }
    
    // MARK: - Child View Controller Management
    
    func add(childViewController child: UIViewController, insets: UIEdgeInsets = .zero) {
        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: insets.top),
            child.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: insets.left),
            child.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -insets.right),
            child.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -insets.bottom)
        ])
        child.didMove(toParent: self)
    }

    func remove(childViewController child: UIViewController) {
        if child.parent != nil {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    // MARK: - Selection Management
    private func select(asset: PHAsset) -> Bool {
        guard !selectedAssets.contains(where: { $0.localIdentifier == asset.localIdentifier }) else {
            return false
        }
        if selectionLimit != 0 && selectedAssets.count >= selectionLimit {
            return false
        }
        selectedAssets.append(asset)
        if rightButtonStyle == .accept {
            navigationItem.rightBarButtonItem?.isEnabled = selectedAssets.count > 0
        }
        delegate?.pickerViewController(self, didUpdateSelection: selectedAssets, hdModeEnabled: hdModeEnabled)
        updateInputBarVisibility()
        updateIsModalInPresentation()
        return true
    }
    
    private func deselect(asset: PHAsset) {
        if let index = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            selectedAssets.remove(at: index)
            if rightButtonStyle == .accept {
                navigationItem.rightBarButtonItem?.isEnabled = selectedAssets.count > 0
            }
            delegate?.pickerViewController(self, didUpdateSelection: selectedAssets, hdModeEnabled: hdModeEnabled)
            updateInputBarVisibility()
            updateIsModalInPresentation()
        }
    }
    
    private func orderFor(asset: PHAsset) -> Int? {
        if let index = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            return index + 1
        }
        return nil
    }
    
    private func updateInputBarVisibility() {
        if let container = pickerWrapperContainer() {
            container.updateInputBarVisibility(selectedAssetCount: selectedAssets.count)
        }
    }
    
    private func updateIsModalInPresentation() {
        let shouldPreventDismissal = selectedAssets.count > 0
        if let container = pickerWrapperContainer() {
            container.isModalInPresentation = shouldPreventDismissal
        } else {
            self.isModalInPresentation = shouldPreventDismissal
        }
    }
    
    private func setPresentationControllerDelegate() {
        if let container = pickerWrapperContainer() {
            container.navigationController?.presentationController?.delegate = container
        } else {
            if let nav = navigationController {
                nav.presentationController?.delegate = self
            }
        }
    }
}

// MARK: - IMAlbumsViewControllerDelegate Implementation
extension IMPickerViewController: IMAlbumsViewControllerDelegate {
    func albumsViewController(_ controller: IMAlbumsViewController, didSelectAlbum album: PHAssetCollection) {
        let viewController = IMAlbumAssetsViewController(album: album)
        viewController.selectionDelegate = self
        viewController.pickerController = self
        viewController.badgeColor = configuration.selectionOverlayBadgeColor
        viewController.contentInsetTop = contentInsetTop != nil ? contentInsetTop! : view.safeAreaInsets.top
        viewController.contentInsetBottom = contentInsetBottom != nil ? contentInsetBottom! : view.safeAreaInsets.bottom
        viewController.navigationItem.title = album.localizedTitle ?? NSLocalizedString("default_album_title", tableName: "IMPhotoPicker", comment: "")
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backFromAlbumDetail)
        )
        viewController.navigationItem.leftBarButtonItem?.tintColor = configuration.leftNavigationItemTintColor
        viewController.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
        navigationController?.pushViewController(viewController, animated: true)
        albumAssetsViewController = viewController
    }
    
    func backFromAlbumDetail() {
        navigationController?.popViewController(animated: true)
        albumAssetsViewController = nil
    }
}

// MARK: - IMAssetSelectionDelegate Implementation
extension IMPickerViewController: IMAssetSelectionDelegate {
    func selectAsset(_ asset: PHAsset) -> Bool {
        return select(asset: asset)
    }
    
    func deselectAsset(_ asset: PHAsset) {
        deselect(asset: asset)
    }
    
    func selectionOrder(for asset: PHAsset) -> Int? {
        return orderFor(asset: asset)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate Implementation
extension IMPickerViewController : UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        delegate?.pickerViewControllerDidAttemptToDismiss(self)
    }
}
