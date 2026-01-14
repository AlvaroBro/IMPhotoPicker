//
//  IMPhotoLibraryPermissionManager.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 11/2/25.
//

import UIKit
import Photos

// MARK: - IMPhotoLibraryPermissionError
public enum IMPhotoLibraryPermissionError: Error {
    case denied
}

// MARK: - IMPhotoLibraryPermissionManager
final class IMPhotoLibraryPermissionManager {
    static let shared = IMPhotoLibraryPermissionManager()
    
    private init() { }
    
    /// Checks photo library authorization and returns a Bool indicating whether access is granted.
    func checkAuthorization(completion: @escaping (Bool) -> Void) {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .authorized, .limited:
                completion(true)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                    DispatchQueue.main.async {
                        completion(newStatus == .authorized || newStatus == .limited)
                    }
                }
            default:
                completion(false)
            }
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
                completion(true)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { newStatus in
                    DispatchQueue.main.async {
                        completion(newStatus == .authorized)
                    }
                }
            default:
                completion(false)
            }
        }
    }
    
    /// Returns true if the app has limited photo library access (iOS 14+).
    @available(iOS 14, *)
    var isLimitedAccess: Bool {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited
    }
    
    /// Presents the limited library picker to allow the user to select more photos.
    /// - Parameter viewController: The view controller from which to present the picker.
    @available(iOS 14, *)
    func presentLimitedLibraryPicker(from viewController: UIViewController) {
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: viewController)
    }
    
    /// Opens the app's settings page in the Settings app.
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}
