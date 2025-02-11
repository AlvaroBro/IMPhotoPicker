//
//  UIViewController+IMExtensions.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 11/2/25.
//

import UIKit

extension UIViewController {
    func findPickerViewController() -> IMPickerViewController? {
        if let picker = self as? IMPickerViewController {
            return picker
        }
        return parent?.findPickerViewController()
    }
}
