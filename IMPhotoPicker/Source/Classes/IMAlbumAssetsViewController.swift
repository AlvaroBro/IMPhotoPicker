//
//  IMAlbumAssetsViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit
import Photos

// MARK: - IMAlbumAssetsViewController
class IMAlbumAssetsViewController: IMAssetsCollectionViewController {
    
    private var album: PHAssetCollection
    
    // MARK: - Initializers
    init(album: PHAssetCollection) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        loadAssets()
    }
    
    // MARK: - Assets Loading
    override func loadAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.applyAssetTypeFilter(from: pickerController)
        self.assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
    }
}
