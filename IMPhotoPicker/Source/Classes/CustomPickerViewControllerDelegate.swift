//
//  CustomPickerViewControllerDelegate.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 6/2/25.
//

import Photos

// MARK: - CustomPickerViewControllerDelegate
/// Delegate protocol for CustomPickerViewController events.
protocol CustomPickerViewControllerDelegate: AnyObject {
    /// Called whenever the selection is updated.
    func customPickerViewController(_ controller: CustomPickerViewController, didUpdateSelection selection: [PHAsset], hdModeEnabled: Bool)
    
    /// Called when the user accepts the selection.
    func customPickerViewController(_ controller: CustomPickerViewController, didFinishPicking selection: [PHAsset], hdModeEnabled: Bool)
    
    /// Called when the user cancels the picker.
    func customPickerViewControllerDidCancel(_ controller: CustomPickerViewController)
    
    /// (Optional) Called when the right bar button is tapped.
    /// This allows the picker presenter to decide how to react.
    func customPickerViewControllerDidTapRightButton(_ controller: CustomPickerViewController)
}

extension CustomPickerViewControllerDelegate {
    func customPickerViewControllerDidTapRightButton(_ controller: CustomPickerViewController) { }
}
