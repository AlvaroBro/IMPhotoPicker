//
//  AlbumsViewControllerDelegate.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import Photos

// MARK: - AlbumsViewControllerDelegate
/// Delegate protocol to notify album selection events.
protocol AlbumsViewControllerDelegate: AnyObject {
    /// Called when an album is selected in AlbumsViewController.
    func albumsViewController(_ controller: AlbumsViewController, didSelectAlbum album: PHAssetCollection)
}
