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
    
    var contentInsetTop: CGFloat = 0 {
        didSet {
            view?.setNeedsLayout()
            view?.layoutIfNeeded()
        }
    }
    var contentInsetBottom: CGFloat = 0 {
        didSet {
            view?.setNeedsLayout()
            view?.layoutIfNeeded()
        }
    }
    var tableView: UITableView!
    var albums: [PHAssetCollection] = []
    let imageManager = PHCachingImageManager()
    weak var delegate: IMAlbumsViewControllerDelegate?
    weak var pickerController: IMPickerViewController?
    var viewDidAppear: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setupTableView()
        checkPhotoLibraryPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !viewDidAppear {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
        }
        viewDidAppear = true
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.contentInset = UIEdgeInsets.init(top: contentInsetTop + 15,
                                                   left: 0,
                                                   bottom: contentInsetBottom,
                                                   right: 0)
    }
    
    // MARK: - Setup
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .interactive
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(IMAlbumCell.self, forCellReuseIdentifier: IMAlbumCell.identifier)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Permissions
    func checkPhotoLibraryPermission() {
        IMPhotoLibraryPermissionManager.shared.checkAuthorization { [weak self] authorized in
            if authorized {
                self?.loadAlbums()
            } else {
                if let picker = self?.pickerController {
                    picker.delegate?.pickerViewController(picker, didFailWithPermissionError: IMPhotoLibraryPermissionError.denied)
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
            fetchOptions.applyAssetTypeFilter(from: pickerController)
            
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

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchOptions.applyAssetTypeFilter(from: pickerController)
        let assetsFetchResult = PHAsset.fetchAssets(in: album, options: fetchOptions)
        
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
        
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == (albums.count - 1)
        cell.updateAppearance(isFirst: isFirst, isLast: isLast)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedAlbum = albums[indexPath.row]
        delegate?.albumsViewController(self, didSelectAlbum: selectedAlbum)
    }
}
