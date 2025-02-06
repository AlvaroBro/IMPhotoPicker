//
//  PhotosViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit
import Photos

class PhotosViewController: AssetsCollectionViewController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPhotoLibraryPermission()
    }
    
    // MARK: - Permissions
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            loadAssets()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    DispatchQueue.main.async {
                        self?.loadAssets()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showNoPermissionAlert()
                    }
                }
            }
        default:
            showNoPermissionAlert()
        }
    }
    
    func showNoPermissionAlert() {
        let alert = UIAlertController(
            title: String(localized: "alert_no_access_title"),
            message: String(localized: "alert_no_access_message"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: String(localized: "alert_ok"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Assets Loading
    override func loadAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.assets = PHAsset.fetchAssets(with: fetchOptions)
        collectionView.reloadData()
    }
}
