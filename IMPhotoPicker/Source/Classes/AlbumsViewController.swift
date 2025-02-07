//
//  AlbumsViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit
import Photos

class AlbumsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    var albums: [PHAssetCollection] = []
    weak var delegate: AlbumsViewControllerDelegate?
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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: AlbumTableViewCell.identifier)
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
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .authorized, .limited:
                loadAlbums()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                    DispatchQueue.main.async {
                        if newStatus == .authorized || newStatus == .limited {
                            self?.loadAlbums()
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
                loadAlbums()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                    DispatchQueue.main.async {
                        if newStatus == .authorized {
                            self?.loadAlbums()
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
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTableViewCell.identifier, for: indexPath) as! AlbumTableViewCell
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
