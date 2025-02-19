//
//  IMPhotosViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit
import Photos

class IMPhotosViewController: IMAssetsCollectionViewController {
    
    // MARK: - Assets Loading
    override func loadAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.applyAssetTypeFilter(from: pickerController)
        self.assets = PHAsset.fetchAssets(with: fetchOptions)
    }
}
