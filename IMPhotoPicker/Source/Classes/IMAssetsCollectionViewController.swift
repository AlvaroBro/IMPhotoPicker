//
//  IMAssetsCollectionViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 6/2/25.
//

import UIKit
import Photos
import AVKit

// MARK: - IMAssetSelectionDelegate
/// Delegate protocol to manage asset selection.
protocol IMAssetSelectionDelegate: AnyObject {
    /// Called when an asset is to be selected. Returns true if the selection succeeded.
    func selectAsset(_ asset: PHAsset) -> Bool
    
    /// Called when an asset should be deselected.
    func deselectAsset(_ asset: PHAsset)
    
    /// Returns the selection order (1-based) for the asset, or nil if not selected.
    func selectionOrder(for asset: PHAsset) -> Int?
}

// MARK: - IMAssetsCollectionViewController
class IMAssetsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var contentInsetTop: CGFloat = 0 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
            updateBannerPosition()
        }
    }
    var contentInsetBottom: CGFloat = 0 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    var collectionView: UICollectionView!
    var assets: PHFetchResult<PHAsset>?
    let imageManager = PHCachingImageManager()
    var badgeColor: UIColor?
    weak var selectionDelegate: IMAssetSelectionDelegate?
    weak var pickerController: IMPickerViewController? {
        didSet {
            // Configure banner when pickerController is set
            configureLimitedAccessBanner()
        }
    }
    
    // MARK: - Limited Access Banner
    private var limitedAccessBannerView: IMLimitedAccessBannerView?
    private var isBannerConfigured = false
    
    /// The height of the limited access banner when visible.
    private var bannerHeight: CGFloat {
        return limitedAccessBannerView?.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height ?? 60
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupLimitedAccessBanner()
        checkPhotoLibraryPermission()
        registerForPhotoLibraryChanges()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) as? IMPhotoCell,
               let asset = assets?[indexPath.item],
               let delegate = selectionDelegate {
                let order = delegate.selectionOrder(for: asset)
                cell.setSelectionOrder(order)
                cell.updateVideoDuration(for: asset, selectionOrder: order)
            }
        }
    }
    
    // MARK: - Setup
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.keyboardDismissMode = .interactive
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(IMPhotoCell.self, forCellWithReuseIdentifier: IMPhotoCell.reuseIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Permissions
    func checkPhotoLibraryPermission() {
        IMPhotoLibraryPermissionManager.shared.checkAuthorization { [weak self] authorized in
            if authorized {
                self?.loadAssetsAndReload()
                self?.updateLimitedAccessBannerVisibility()
            } else {
                if let picker = self?.pickerController {
                    picker.delegate?.pickerViewController(picker, didFailWithPermissionError: IMPhotoLibraryPermissionError.denied)
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IMPhotoCell.reuseIdentifier, for: indexPath) as? IMPhotoCell else {
            fatalError("Failed to dequeue cell")
        }
        
        if let asset = assets?[indexPath.item] {
            cell.representedAssetIdentifier = asset.localIdentifier
            let scale = UIScreen.main.scale
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            let itemSize = layout?.itemSize ?? CGSize(width: 100, height: 100)
            let targetSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
            
            imageManager.requestImage(for: asset,
                                      targetSize: targetSize,
                                      contentMode: .aspectFill,
                                      options: nil) { [weak cell] image, _ in
                DispatchQueue.main.async {
                    if cell?.representedAssetIdentifier == asset.localIdentifier {
                        cell?.imageView.image = image
                    }
                }
            }
            
            let order = selectionDelegate?.selectionOrder(for: asset)
            cell.setSelectionOrder(order)
            cell.updateVideoDuration(for: asset, selectionOrder: order)
            cell.badgeColor = badgeColor ?? .systemBlue
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = assets?[indexPath.item],
              let delegate = selectionDelegate else { return }
        
        if delegate.selectionOrder(for: asset) != nil {
            delegate.deselectAsset(asset)
        } else {
            _ = delegate.selectAsset(asset)
        }
        
        for ip in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: ip) as? IMPhotoCell,
               let assetForCell = assets?[ip.item] {
                let order = delegate.selectionOrder(for: assetForCell)
                cell.setSelectionOrder(order)
                cell.updateVideoDuration(for: assetForCell, selectionOrder: order)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let asset = assets?[indexPath.item] else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            if asset.mediaType == .video {
                let playerVC = AVPlayerViewController()
                playerVC.showsPlaybackControls = false
                playerVC.view.backgroundColor = .clear
                PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { avAsset, _, _ in
                    DispatchQueue.main.async {
                        if let avAsset = avAsset {
                            let playerItem = AVPlayerItem(asset: avAsset)
                            let player = AVPlayer(playerItem: playerItem)
                            playerVC.player = player
                            player.play()
                        }
                    }
                }
                return playerVC
            } else {
                let previewVC = UIViewController()
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFit
                imageView.frame = previewVC.view.bounds
                imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.imageManager.requestImage(for: asset, targetSize: previewVC.view.bounds.size, contentMode: .aspectFit, options: nil) { image, _ in
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
                previewVC.view.addSubview(imageView)
                return previewVC
            }
        }, actionProvider: { _ in
            return UIMenu(title: "", children: [])
        })
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let minRows: CGFloat = 3
        let padding: CGFloat = 2
        let totalPadding = padding * (minRows - 1)
        let baseItemSize: CGFloat = 120
        let availableWidth = collectionView.bounds.width - totalPadding
        let itemsPerRow = max(minRows, floor(availableWidth / baseItemSize))
        let adjustedPadding = padding * (itemsPerRow - 1)
        let itemWidth = (collectionView.bounds.width - adjustedPadding) / itemsPerRow
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let baseTopInset = contentInsetTop > 0 ? contentInsetTop : view.safeAreaInsets.top
        let totalTopInset = baseTopInset + limitedAccessBannerInset
        
        return UIEdgeInsets(top: totalTopInset,
                            left: 0,
                            bottom: contentInsetBottom > 0 ? contentInsetBottom : view.safeAreaInsets.bottom,
                            right: 0)
    }
    
    // MARK: - Private methods
    func loadAssetsAndReload() {
        loadAssets()
        UIView.performWithoutAnimation {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }
    }
    
    // MARK: - Abstract Method
    /// Subclasses must override this method to load assets.
    func loadAssets() {
        // Implementation in subclasses.
    }
    
    // MARK: - Limited Access Banner Setup
    
    private var bannerTopConstraint: NSLayoutConstraint?
    
    private func setupLimitedAccessBanner() {
        let bannerView = IMLimitedAccessBannerView()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.isHidden = true
        
        bannerView.onManageTapped = { [weak self] in
            self?.showLimitedAccessActionSheet()
        }
        
        view.addSubview(bannerView)
        
        // Position at top, will be adjusted in viewDidLayoutSubviews
        bannerTopConstraint = bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        
        NSLayoutConstraint.activate([
            bannerTopConstraint!,
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        limitedAccessBannerView = bannerView
        
        // Apply configuration if pickerController was already set
        configureLimitedAccessBanner()
    }
    
    /// Configures the banner with custom settings from pickerController.
    /// Called when pickerController is set.
    private func configureLimitedAccessBanner() {
        guard !isBannerConfigured, let bannerView = limitedAccessBannerView else { return }
        
        if let config = pickerController?.configuration {
            // Hide banner view entirely if disabled
            if !config.showLimitedAccessBanner {
                bannerView.removeFromSuperview()
                limitedAccessBannerView = nil
                return
            }
            
            if let message = config.limitedAccessBannerMessage {
                bannerView.setMessage(message)
            }
            if let buttonTitle = config.limitedAccessManageButtonTitle {
                bannerView.setManageButtonTitle(buttonTitle)
            }
            if let messageColor = config.limitedAccessBannerMessageColor {
                bannerView.messageTextColor = messageColor
            }
            if let linkColor = config.limitedAccessManageButtonColor {
                bannerView.manageLinkColor = linkColor
            }
            if let font = config.limitedAccessBannerFont {
                bannerView.textFont = font
            }
        }
        
        isBannerConfigured = true
    }
    
    private func updateLimitedAccessBannerVisibility() {
        guard let bannerView = limitedAccessBannerView,
              pickerController?.configuration.showLimitedAccessBanner ?? true else { return }
        
        if #available(iOS 14, *) {
            let shouldShowBanner = IMPhotoLibraryPermissionManager.shared.isLimitedAccess
            
            if bannerView.isHidden == shouldShowBanner {
                bannerView.isHidden = !shouldShowBanner
                
                // Update collection view content inset
                UIView.animate(withDuration: 0.25) {
                    self.collectionView.collectionViewLayout.invalidateLayout()
                }
            }
        }
    }
    
    /// Returns the extra top inset needed for the limited access banner.
    var limitedAccessBannerInset: CGFloat {
        guard let bannerView = limitedAccessBannerView,
              !bannerView.isHidden else { return 0 }
        return bannerHeight
    }
    
    /// Updates the banner position based on content insets.
    private func updateBannerPosition() {
        // Banner is anchored to safe area top, no adjustment needed
        // The collection view inset accounts for the banner height
    }
    
    // MARK: - Limited Access Action Sheet
    
    private func showLimitedAccessActionSheet() {
        let config = pickerController?.configuration
        
        let title = config?.limitedAccessActionSheetTitle
            ?? NSLocalizedString("limited_access_action_sheet_title", tableName: "IMPhotoPicker", comment: "")
        
        let selectMoreTitle = config?.limitedAccessSelectMoreTitle
            ?? NSLocalizedString("limited_access_select_more", tableName: "IMPhotoPicker", comment: "")
        
        let changeSettingsTitle = config?.limitedAccessChangeSettingsTitle
            ?? NSLocalizedString("limited_access_change_settings", tableName: "IMPhotoPicker", comment: "")
        
        let cancelTitle = NSLocalizedString("cancel_button_title", tableName: "IMPhotoPicker", comment: "")
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        // Select more photos action
        if #available(iOS 14, *) {
            let selectMoreAction = UIAlertAction(title: selectMoreTitle, style: .default) { [weak self] _ in
                guard let self = self else { return }
                IMPhotoLibraryPermissionManager.shared.presentLimitedLibraryPicker(from: self)
            }
            alert.addAction(selectMoreAction)
        }
        
        // Change settings action
        let changeSettingsAction = UIAlertAction(title: changeSettingsTitle, style: .default) { _ in
            IMPhotoLibraryPermissionManager.shared.openAppSettings()
        }
        alert.addAction(changeSettingsAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
        alert.addAction(cancelAction)
        
        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = limitedAccessBannerView
            popover.sourceRect = limitedAccessBannerView?.bounds ?? .zero
        }
        
        present(alert, animated: true)
    }
    
    // MARK: - Photo Library Change Observer
    
    private func registerForPhotoLibraryChanges() {
        PHPhotoLibrary.shared().register(self)
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension IMAssetsCollectionViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Reload assets when the photo library changes
            if let currentAssets = self.assets,
               let changes = changeInstance.changeDetails(for: currentAssets) {
                self.assets = changes.fetchResultAfterChanges
                
                if changes.hasIncrementalChanges {
                    self.collectionView.performBatchUpdates({
                        if let removed = changes.removedIndexes, !removed.isEmpty {
                            self.collectionView.deleteItems(at: removed.map { IndexPath(item: $0, section: 0) })
                        }
                        if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                            self.collectionView.insertItems(at: inserted.map { IndexPath(item: $0, section: 0) })
                        }
                        if let changed = changes.changedIndexes, !changed.isEmpty {
                            self.collectionView.reloadItems(at: changed.map { IndexPath(item: $0, section: 0) })
                        }
                        changes.enumerateMoves { fromIndex, toIndex in
                            self.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                        to: IndexPath(item: toIndex, section: 0))
                        }
                    })
                } else {
                    self.collectionView.reloadData()
                }
                
                // Clear selection when photos change
                self.pickerController?.clearSelection()
                
                // Refresh visible cells to update selection state
                self.refreshVisibleCellsSelection()
                
            } else {
                // Full reload if we can't get incremental changes
                self.loadAssetsAndReload()
                
                // Clear selection when photos change
                self.pickerController?.clearSelection()
                
                // Refresh visible cells to update selection state
                self.refreshVisibleCellsSelection()
            }
            
            // Update banner visibility (in case permissions changed)
            self.updateLimitedAccessBannerVisibility()
        }
    }
    
    /// Refreshes the selection state of all visible cells.
    private func refreshVisibleCellsSelection() {
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) as? IMPhotoCell,
               let asset = assets?[indexPath.item],
               let delegate = selectionDelegate {
                let order = delegate.selectionOrder(for: asset)
                cell.setSelectionOrder(order)
                cell.updateVideoDuration(for: asset, selectionOrder: order)
            }
        }
    }
}
