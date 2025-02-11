//
//  IMAlbumsViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit
import Photos

// MARK: - IMAlbumsViewControllerDelegate
/// Delegate protocol to notify album selection events.
protocol IMAlbumsViewControllerDelegate: AnyObject {
    /// Called when an album is selected in IMAlbumsViewController.
    func albumsViewController(_ controller: IMAlbumsViewController, didSelectAlbum album: PHAssetCollection)
}

class IMAlbumsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    var albums: [PHAssetCollection] = []
    weak var delegate: IMAlbumsViewControllerDelegate?
    let imageManager = PHCachingImageManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setupTableView()
        checkPhotoLibraryPermission()
    }
    
    // MARK: - Setup
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .interactive
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(IMAlbumCell.self, forCellReuseIdentifier: IMAlbumCell.identifier)
        tableView.layer.cornerRadius = 12
        tableView.clipsToBounds = true
        view.addSubview(tableView)
        
        let margin: CGFloat = 15
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: margin),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -margin),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin)
        ])
    }
    
    // MARK: - Permissions
    func checkPhotoLibraryPermission() {
        IMPhotoLibraryPermissionManager.shared.checkAuthorization { [weak self] authorized in
            DispatchQueue.main.async {
                if authorized {
                    self?.loadAlbums()
                } else {
                    if let pickerVC = self?.findPickerViewController() {
                        pickerVC.delegate?.pickerViewController(pickerVC, didFailWithPermissionError: IMPhotoLibraryPermissionError.denied)
                    }
                }
            }
        }
    }
    
    // MARK: - Assets Loading
    func loadAlbums() {
        var albumCollections: [PHAssetCollection] = []
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        smartAlbums.enumerateObjects { (collection, _, _) in
            albumCollections.append(collection)
        }
        
        let userAlbums = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        userAlbums.enumerateObjects { (collection, _, _) in
            if let assetCollection = collection as? PHAssetCollection {
                albumCollections.append(assetCollection)
            }
        }
        
        self.albums = albumCollections.filter { album in
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let assetsFetchResult = PHAsset.fetchAssets(in: album, options: fetchOptions)
            return assetsFetchResult.count > 0
        }
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IMAlbumCell.identifier, for: indexPath) as! IMAlbumCell
        let album = albums[indexPath.row]
        cell.titleLabel.text = album.localizedTitle
        let assetsFetchResult = PHAsset.fetchAssets(in: album, options: nil)
        if let lastAsset = assetsFetchResult.lastObject {
            let targetSize = CGSize(width: 100, height: 100)
            imageManager.requestImage(for: lastAsset,
                                      targetSize: targetSize,
                                      contentMode: .aspectFill,
                                      options: nil) { image, _ in
                DispatchQueue.main.async {
                    cell.albumImageView.image = image
                }
            }
        } else {
            cell.albumImageView.image = nil
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedAlbum = albums[indexPath.row]
        delegate?.albumsViewController(self, didSelectAlbum: selectedAlbum)
    }
}
