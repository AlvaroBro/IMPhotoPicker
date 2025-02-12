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
    
    let customPicker1Button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Custom Picker Example 1", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let customPicker2Button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Custom Picker Example 2", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let customPicker3Button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Custom Picker Example 3", for: .normal)
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
        view.addSubview(customPicker1Button)
        view.addSubview(customPicker2Button)
        view.addSubview(customPicker3Button)
        
        nativePickerButton.addTarget(self, action: #selector(presentNativePicker), for: .touchUpInside)
        customPicker1Button.addTarget(self, action: #selector(presentPicker1), for: .touchUpInside)
        customPicker2Button.addTarget(self, action: #selector(presentPicker2), for: .touchUpInside)
        customPicker3Button.addTarget(self, action: #selector(presentPicker3), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            nativePickerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nativePickerButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            customPicker1Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customPicker1Button.topAnchor.constraint(equalTo: nativePickerButton.bottomAnchor, constant: 20),
            
            customPicker2Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customPicker2Button.topAnchor.constraint(equalTo: customPicker1Button.bottomAnchor, constant: 20),
            
            customPicker3Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customPicker3Button.topAnchor.constraint(equalTo: customPicker2Button.bottomAnchor, constant: 20)
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
    
    @objc func presentPicker1() {
        let picker = IMPickerViewController()
        picker.delegate = self
        let navController = UINavigationController(rootViewController: picker)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    @objc func presentPicker2() {
        let picker = IMPickerViewController()
        let customButton = UIBarButtonItem(title: "Custom", style: .done, target: self, action: #selector(customRightButtonTapped))
        picker.configuration = IMPickerConfiguration(
            rightButtonStyle: .custom(customButton),
            maxSelectionCount: 3,
            cancelButtonNavigationItemTintColor: .red,
            leftNavigationItemTintColor: .blue,
            rightNavigationItemTintColor: .blue,
            segmentedControlTintColor: .white,
            segmentedControlSelectedSegmentTintColor: .black,
            segmentedControlTextAttributes: [.foregroundColor: UIColor.black],
            segmentedControlSelectedTextAttributes: [.foregroundColor: UIColor.white]
        )
        picker.delegate = self
        let navController = UINavigationController(rootViewController: picker)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }

    @objc func presentPicker3() {
        let picker = IMPickerWrapperViewController()
        picker.configuration = IMPickerConfiguration(
            rightButtonStyle: .hdModeToggle,
            cancelButtonNavigationItemTintColor: .black,
            leftNavigationItemTintColor: .black,
            rightNavigationItemTintColor: .black,
            selectionOverlayBadgeColor: .systemGreen,
            inputBarConfiguration: IMPickerConfiguration.InputBarConfiguration(
                        placeholder: "Enter your message...",
                        sendButtonBackgroundColor: .systemGreen,
                        sendButtonBadgeColor: .systemGreen
                    )
        )
        picker.delegate = self
        presentPickerWrapperAsPageSheet(picker: picker)
    }
    
    func presentPickerWrapperAsPageSheet(picker: IMPickerWrapperViewController) {
        if #available(iOS 15.0, *) {
            picker.modalPresentationStyle = .pageSheet
            if let sheet = picker.sheetPresentationController {
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
                present(picker, animated: true)
            }
        } else {
            picker.modalPresentationStyle = .pageSheet
            present(picker, animated: true, completion: nil)
        }
    }
    
    @objc func customRightButtonTapped() {
        print("Custom button tapped")
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
