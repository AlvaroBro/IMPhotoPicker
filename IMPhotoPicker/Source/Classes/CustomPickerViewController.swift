//
//  CustomPickerViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit
import Photos

class CustomPickerViewController: UIViewController {

    enum CustomPickerRightButtonStyle: Equatable {
        case accept
        case hdModeToggle
        case custom(UIBarButtonItem)
    }

    // MARK: - Main Properties
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: [
            String(localized: "photos_segment_title"),
            String(localized: "albums_segment_title")
        ])
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    let containerView = UIView()
    
    let photosVC = PhotosViewController()
    let albumsVC = AlbumsViewController()
    
    var rightButtonStyle: CustomPickerRightButtonStyle = .accept
    var hdModeEnabled: Bool = false
    private var selectedAssets: [PHAsset] = []
    let maxSelectionCount: Int = 5
    
    weak var delegate: CustomPickerViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setupNavigationBar()
        setupContainerView()
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        photosVC.selectionDelegate = self
        add(childViewController: photosVC)
        albumsVC.delegate = self
    }
    
    // MARK: - Navigation Bar Setup
    func setupNavigationBar() {
        navigationItem.titleView = segmentedControl
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: String(localized: "cancel_button_title"),
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        switch rightButtonStyle {
        case .accept:
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: String(localized: "accept_button_title"),
                style: .done,
                target: self,
                action: #selector(acceptTapped)
            )
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = .black
        case .hdModeToggle:
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: hdModeImage(),
                style: .plain,
                target: self,
                action: #selector(toggleHDMode)
            )
        case .custom(let item):
            navigationItem.rightBarButtonItem = item
        }
    }
    
    // MARK: - Container View Setup
    func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Navigation Bar Actions
    @objc func cancelTapped() {
        delegate?.customPickerViewControllerDidCancel(self)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func acceptTapped() {
        delegate?.customPickerViewControllerDidTapRightButton(self)
        delegate?.customPickerViewController(self, didFinishPicking: selectedAssets, hdModeEnabled: hdModeEnabled)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func toggleHDMode() {
        hdModeEnabled.toggle()
        navigationItem.rightBarButtonItem?.image = hdModeImage()
        print("HD Mode: \(hdModeEnabled ? "Enabled" : "Disabled")")
        delegate?.customPickerViewControllerDidTapRightButton(self)
        delegate?.customPickerViewController(self, didUpdateSelection: selectedAssets, hdModeEnabled: hdModeEnabled)
    }
    
    private func hdModeImage() -> UIImage? {
        let imageName = hdModeEnabled ? "deselect-hd" : "select-hd"
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
        remove(childViewController: albumsVC)
        if photosVC.parent == nil {
            add(childViewController: photosVC)
        }
        navigationItem.titleView = segmentedControl
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: String(localized: "cancel_button_title"),
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    func switchToAlbums() {
        remove(childViewController: photosVC)
        if albumsVC.parent == nil {
            add(childViewController: albumsVC)
        }
        navigationItem.titleView = segmentedControl
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: String(localized: "cancel_button_title"),
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    // MARK: - Child View Controller Management
    func add(childViewController child: UIViewController) {
        addChild(child)
        child.view.frame = containerView.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(child.view)
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
    /// Attempts to select the given asset; returns true if successful.
    private func select(asset: PHAsset) -> Bool {
        guard !selectedAssets.contains(where: { $0.localIdentifier == asset.localIdentifier }),
              selectedAssets.count < maxSelectionCount else {
            return false
        }
        selectedAssets.append(asset)
        if rightButtonStyle == .accept {
            navigationItem.rightBarButtonItem?.isEnabled = selectedAssets.count > 0
        }
        delegate?.customPickerViewController(self, didUpdateSelection: selectedAssets, hdModeEnabled: hdModeEnabled)
        return true
    }
    
    /// Deselects the given asset if selected.
    private func deselect(asset: PHAsset) {
        if let index = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            selectedAssets.remove(at: index)
            if rightButtonStyle == .accept {
                navigationItem.rightBarButtonItem?.isEnabled = selectedAssets.count > 0
            }
            delegate?.customPickerViewController(self, didUpdateSelection: selectedAssets, hdModeEnabled: hdModeEnabled)
        }
    }
    
    /// Returns the 1-based selection order for the asset, or nil if not selected.
    private func orderFor(asset: PHAsset) -> Int? {
        if let index = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            return index + 1
        }
        return nil
    }
}

// MARK: - AlbumsViewControllerDelegate Implementation
extension CustomPickerViewController: AlbumsViewControllerDelegate {
    func albumsViewController(_ controller: AlbumsViewController, didSelectAlbum album: PHAssetCollection) {
        let albumDetailVC = AlbumDetailViewController(album: album)
        albumDetailVC.selectionDelegate = self
        albumDetailVC.navigationItem.title = album.localizedTitle ?? String(localized: "default_album_title")
        albumDetailVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backFromAlbumDetail)
        )
        albumDetailVC.navigationItem.leftBarButtonItem?.tintColor = .black
        albumDetailVC.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
        navigationController?.pushViewController(albumDetailVC, animated: true)
    }
    
    @objc func backFromAlbumDetail() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - AssetSelectionDelegate Implementation
extension CustomPickerViewController: AssetSelectionDelegate {
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
