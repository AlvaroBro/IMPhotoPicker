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
    
    /// The maximum number of assets that can be selected.
    var maxSelectionCount: Int { get }
}


// MARK: - IMAssetsCollectionViewController
class IMAssetsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var assets: PHFetchResult<PHAsset>?
    let imageManager = PHCachingImageManager()
    weak var selectionDelegate: IMAssetSelectionDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        checkPhotoLibraryPermission()
    }
    
    // MARK: - Setup
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.keyboardDismissMode = .interactive
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(IMPhotoCell.self, forCellWithReuseIdentifier: IMPhotoCell.reuseIdentifier)
        
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
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .authorized, .limited:
                loadAssetsAndReload()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                    DispatchQueue.main.async {
                        if newStatus == .authorized || newStatus == .limited {
                            self?.loadAssetsAndReload()
                        } else {
                            self?.showNoPermissionAlert()
                        }
                    }
                }
            default:
                showNoPermissionAlert()
            }
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
                loadAssetsAndReload()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                    DispatchQueue.main.async {
                        if newStatus == .authorized {
                            self?.loadAssetsAndReload()
                        } else {
                            self?.showNoPermissionAlert()
                        }
                    }
                }
            default:
                showNoPermissionAlert()
            }
        }
    }
    
    // MARK: - Alerts
    func showNoPermissionAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("alert_no_access_title", comment: ""),
            message: NSLocalizedString("alert_no_access_message", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert_ok", comment: ""), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
            let scale = UIScreen.main.scale
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            let itemSize = layout?.itemSize ?? CGSize(width: 100, height: 100)
            let targetSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
            
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { image, _ in
                DispatchQueue.main.async {
                    cell.imageView.image = image
                }
            }
            
            let order = selectionDelegate?.selectionOrder(for: asset)
            cell.setSelectionOrder(order)
            cell.updateVideoDuration(for: asset, selectionOrder: order)
        }
        return cell
    }
    
    // MARK: - View Updates
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
        let spacing: CGFloat = 2
        let totalSpacing = spacing * 2
        let width = (collectionView.bounds.width - totalSpacing) / 3
        return CGSize(width: width, height: width)
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
}
