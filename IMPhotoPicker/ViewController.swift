//
//  ViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {

    // MARK: - UI Properties

    let nativePickerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Native Picker", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let customPickerAcceptButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Custom Picker Example 1", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let customPickerHDButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Custom Picker Example 2", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    // MARK: - UI Setup

    func setupUI() {
        view.addSubview(nativePickerButton)
        view.addSubview(customPickerAcceptButton)
        view.addSubview(customPickerHDButton)
        
        nativePickerButton.addTarget(self, action: #selector(presentNativePicker), for: .touchUpInside)
        customPickerAcceptButton.addTarget(self, action: #selector(presentPicker2), for: .touchUpInside)
        customPickerHDButton.addTarget(self, action: #selector(presentPicker3), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            nativePickerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nativePickerButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            customPickerAcceptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customPickerAcceptButton.topAnchor.constraint(equalTo: nativePickerButton.bottomAnchor, constant: 20),
            
            customPickerHDButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customPickerHDButton.topAnchor.constraint(equalTo: customPickerAcceptButton.bottomAnchor, constant: 20)
        ])
    }
    
    // MARK: - Actions

    @objc func presentNativePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = nil
        configuration.selectionLimit = 0
        configuration.preferredAssetRepresentationMode = .automatic
        configuration.selection = .ordered
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func presentPicker2() {
        let picker = IMPickerViewController()
        picker.rightButtonStyle = .accept
        picker.delegate = self
        let navController = UINavigationController(rootViewController: picker)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }

    @objc func presentPicker3() {
        let container = IMPickerWrapperViewController()
        container.containerDelegate = self
        
        if #available(iOS 15.0, *) {
            container.modalPresentationStyle = .pageSheet
            if let sheet = container.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [
                        .custom(identifier: .init("custom.detent")) { context in
                            return context.maximumDetentValue * 0.65
                        },
                        .large()
                    ]
                } else if #available(iOS 15.0, *) {
                    sheet.detents = [
                        .medium(),
                        .large()
                    ]
                }
                sheet.preferredCornerRadius = 20
                present(container, animated: true)
            }
        } else {
            container.modalPresentationStyle = .pageSheet
            present(container, animated: true, completion: nil)
        }
    }
    
    // MARK: - Alerts
    func showNoPermissionAlert(fromViewController: UIViewController) {
        let alert = UIAlertController(
            title: NSLocalizedString("alert_no_access_title", comment: ""),
            message: NSLocalizedString("alert_no_access_message", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert_ok", comment: ""), style: .default, handler: { UIAlertAction in
            fromViewController.dismiss(animated: true)
        }))
        fromViewController.present(alert, animated: true, completion: nil)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
    }
}

// MARK: - IMPickerViewControllerDelegate

extension ViewController: IMPickerWrapperViewControllerDelegate {
    func pickerViewController(_ controller: IMPickerViewController, didUpdateSelection selection: [PHAsset], hdModeEnabled: Bool) {
        print("Updated selection: \(selection.count) items, HD mode: \(hdModeEnabled ? "Enabled" : "Disabled")")
    }
    
    func pickerViewController(_ controller: IMPickerViewController, didFinishPicking selection: [PHAsset], hdModeEnabled: Bool) {
        print("Finished picking: \(selection.count) items, HD mode: \(hdModeEnabled ? "Enabled" : "Disabled")")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func pickerViewControllerDidCancel(_ controller: IMPickerViewController) {
        print("Picker canceled")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func pickerViewControllerDidTapRightButton(_ controller: IMPickerViewController) {
        print("Right button tapped")
    }
    
    func pickerWrapperViewController(_ controller: IMPickerWrapperViewController, didTapSendWithText text: String) {
        print("Send tapped with text: \(text)")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func pickerViewController(_ controller: IMPickerViewController, didFailWithPermissionError error: Error) {
        print("Permission error: \(error)")
        showNoPermissionAlert(fromViewController: controller)
    }
}
