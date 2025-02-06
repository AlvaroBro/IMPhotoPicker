//
//  AlbumDetailViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit
import Photos

// MARK: - AlbumDetailViewController
class AlbumDetailViewController: AssetsCollectionViewController {
    
    // Public property representing the album whose assets will be fetched.
    let album: PHAssetCollection
    
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
        loadAssets()
    }
    
    // MARK: - Assets Loading
    override func loadAssets() {
        self.assets = PHAsset.fetchAssets(in: album, options: nil)
        collectionView.reloadData()
    }
}
