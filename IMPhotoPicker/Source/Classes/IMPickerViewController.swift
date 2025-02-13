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
public protocol IMPickerViewControllerDelegate: AnyObject {
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
}

extension IMPickerViewControllerDelegate {
    func pickerViewControllerDidTapRightButton(_ controller: IMPickerViewController) { }
    func pickerViewController(_ controller: IMPickerViewController, didFailWithPermissionError error: Error) { }
}

public class IMPickerViewController: UIViewController {

    // MARK: - Types
    public enum CustomPickerRightButtonStyle: Equatable {
        case accept
        case hdModeToggle
        case custom(UIBarButtonItem)
    }

    // MARK: - Public Properties
    
    var selectionLimit: Int {
        configuration.selectionLimit
    }
    
    var rightButtonStyle: CustomPickerRightButtonStyle {
        configuration.rightButtonStyle
    }
    
    var configuration: IMPickerConfiguration = IMPickerConfiguration()
    
    var contentInsetBottom: CGFloat = 0 {
        didSet {
            photosViewController.contentInsetBottom = contentInsetBottom
            albumsViewController.contentInsetBottom = contentInsetBottom
            albumAssetsViewController?.contentInsetBottom = contentInsetBottom
        }
    }
    
    weak var delegate: IMPickerViewControllerDelegate?
    
    // MARK: - Private Properties
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: [
            NSLocalizedString("photos_segment_title", comment: ""),
            NSLocalizedString("albums_segment_title", comment: "")
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
        setupContainerView()
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        photosViewController.badgeColor = configuration.selectionOverlayBadgeColor
        photosViewController.selectionDelegate = self
        photosViewController.pickerController = self
        add(childViewController: photosViewController)
        albumsViewController.delegate = self
        albumsViewController.pickerController = self
    }
    
    // MARK: - Navigation Bar Setup
    func setupNavigationBar() {
        segmentedControl.selectedSegmentTintColor = configuration.segmentedControlSelectedSegmentTintColor
        segmentedControl.backgroundColor = configuration.segmentedControlTintColor
        segmentedControl.setTitleTextAttributes(configuration.segmentedControlTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(configuration.segmentedControlSelectedTextAttributes, for: .selected)
        
        navigationItem.titleView = segmentedControl
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("cancel_button_title", comment: ""),
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = configuration.cancelButtonNavigationItemTintColor
        
        switch rightButtonStyle {
        case .accept:
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("accept_button_title", comment: ""),
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
        case .custom(let item):
            navigationItem.rightBarButtonItem = item
            item.tintColor = configuration.rightNavigationItemTintColor
        }
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
    
    // MARK: - Navigation Bar Actions
    @objc func cancelTapped() {
        delegate?.pickerViewControllerDidCancel(self)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func acceptTapped() {
        delegate?.pickerViewControllerDidTapRightButton(self)
        delegate?.pickerViewController(self, didFinishPicking: selectedAssets, hdModeEnabled: hdModeEnabled)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func toggleHDMode() {
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
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            switchToPhotos()
        } else {
            switchToAlbums()
        }
    }
    
    func switchToPhotos() {
        remove(childViewController: albumsViewController)
        if photosViewController.parent == nil {
            add(childViewController: photosViewController)
        }
    }
    
    func switchToAlbums() {
        remove(childViewController: photosViewController)
        if albumsViewController.parent == nil {
            add(childViewController: albumsViewController)
        }
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
        updateInputBarVisibilityIfNeeded()
        return true
    }
    
    private func deselect(asset: PHAsset) {
        if let index = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            selectedAssets.remove(at: index)
            if rightButtonStyle == .accept {
                navigationItem.rightBarButtonItem?.isEnabled = selectedAssets.count > 0
            }
            delegate?.pickerViewController(self, didUpdateSelection: selectedAssets, hdModeEnabled: hdModeEnabled)
            updateInputBarVisibilityIfNeeded()
        }
    }
    
    private func orderFor(asset: PHAsset) -> Int? {
        if let index = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            return index + 1
        }
        return nil
    }
    
    private func updateInputBarVisibilityIfNeeded() {
        if let container = self.navigationController?.parent as? IMPickerWrapperViewController {
            container.updateInputBarVisibility(selectedAssetCount: selectedAssets.count)
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
        viewController.contentInsetBottom = contentInsetBottom
        viewController.navigationItem.title = album.localizedTitle ?? NSLocalizedString("default_album_title", comment: "")
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
    
    @objc func backFromAlbumDetail() {
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
