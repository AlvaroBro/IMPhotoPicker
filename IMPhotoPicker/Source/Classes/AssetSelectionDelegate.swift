//
//  AssetSelectionDelegate.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import Photos

// MARK: - AssetSelectionDelegate
/// Delegate protocol to manage asset selection.
protocol AssetSelectionDelegate: AnyObject {
    /// Called when an asset is to be selected. Returns true if the selection succeeded.
    func selectAsset(_ asset: PHAsset) -> Bool
    
    /// Called when an asset should be deselected.
    func deselectAsset(_ asset: PHAsset)
    
    /// Returns the selection order (1-based) for the asset, or nil if not selected.
    func selectionOrder(for asset: PHAsset) -> Int?
    
    /// The maximum number of assets that can be selected.
    var maxSelectionCount: Int { get }
}
